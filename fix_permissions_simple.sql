-- 1. Primeiro, vamos criar uma função mais simples para teste
CREATE OR REPLACE FUNCTION public.test_upsert_permissions(
  p_user_id uuid,
  p_permissions jsonb
) 
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  result jsonb;
  is_admin boolean;
BEGIN
  -- Verifica se o usuário é administrador
  SELECT EXISTS (
    SELECT 1 
    FROM auth.users 
    WHERE id = auth.uid() 
    AND raw_user_meta_data->>'role' = 'admin'
  ) INTO is_admin;
  
  -- Se não for admin, verifica se está tentando atualizar as próprias permissões
  IF NOT is_admin AND auth.uid() <> p_user_id THEN
    RAISE EXCEPTION 'Apenas administradores podem atualizar permissões de outros usuários';
  END IF;
  
  -- Log para depuração
  RAISE NOTICE 'Atualizando permissões para o usuário %', p_user_id;
  RAISE NOTICE 'Permissões: %', p_permissions::text;
  
  -- Faz o upsert das permissões
  INSERT INTO public.user_permissions (
    user_id,
    can_access_dashboard,
    can_access_whatsapp,
    can_access_ai_agents,
    can_access_colaboradores,
    can_access_configuracoes,
    can_access_administracao,
    updated_at
  )
  VALUES (
    p_user_id,
    COALESCE(p_permissions->>'can_access_dashboard', 'false')::boolean,
    COALESCE(p_permissions->>'can_access_whatsapp', 'false')::boolean,
    COALESCE(p_permissions->>'can_access_ai_agents', 'false')::boolean,
    COALESCE(p_permissions->>'can_access_colaboradores', 'false')::boolean,
    COALESCE(p_permissions->>'can_access_configuracoes', 'false')::boolean,
    COALESCE(p_permissions->>'can_access_administracao', 'false')::boolean,
    NOW()
  )
  ON CONFLICT (user_id) 
  DO UPDATE SET
    can_access_dashboard = EXCLUDED.can_access_dashboard,
    can_access_whatsapp = EXCLUDED.can_access_whatsapp,
    can_access_ai_agents = EXCLUDED.can_access_ai_agents,
    can_access_colaboradores = EXCLUDED.can_access_colaboradores,
    can_access_configuracoes = EXCLUDED.can_access_configuracoes,
    can_access_administracao = EXCLUDED.can_access_administracao,
    updated_at = NOW()
  RETURNING to_jsonb(public.user_permissions.*) INTO result;
  
  RETURN jsonb_build_object('success', true, 'data', result);
EXCEPTION
  WHEN others THEN
    RETURN jsonb_build_object(
      'success', false,
      'error', SQLERRM,
      'state', SQLSTATE
    );
END;
$$;

-- Permite que usuários autenticados executem a função
GRANT EXECUTE ON FUNCTION public.test_upsert_permissions(uuid, jsonb) TO authenticated;

-- 2. Atualiza as políticas RLS para garantir que tudo funcione
ALTER TABLE public.user_permissions ENABLE ROW LEVEL SECURITY;

-- Política para leitura das próprias permissões
DROP POLICY IF EXISTS "users_read_own_permissions" ON public.user_permissions;
CREATE POLICY "users_read_own_permissions" 
ON public.user_permissions
FOR SELECT
USING (auth.uid() = user_id);

-- Política para administradores (acesso total)
DROP POLICY IF EXISTS "admins_full_access" ON public.user_permissions;
CREATE POLICY "admins_full_access" 
ON public.user_permissions
FOR ALL
USING (
  EXISTS (
    SELECT 1 
    FROM auth.users 
    WHERE id = auth.uid() 
    AND raw_user_meta_data->>'role' = 'admin'
  )
);

-- Política para usuários atualizarem suas próprias permissões
DROP POLICY IF EXISTS "users_update_own_permissions" ON public.user_permissions;
CREATE POLICY "users_update_own_permissions"
ON public.user_permissions
FOR UPDATE
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- Política para usuários criarem suas próprias permissões
DROP POLICY IF EXISTS "users_insert_own_permissions" ON public.user_permissions;
CREATE POLICY "users_insert_own_permissions"
ON public.user_permissions
FOR INSERT
WITH CHECK (auth.uid() = user_id);

-- 3. Garante que a tabela tem as permissões corretas
GRANT ALL ON public.user_permissions TO authenticated, service_role;
GRANT ALL ON SEQUENCE public.user_permissions_id_seq TO authenticated, service_role;
