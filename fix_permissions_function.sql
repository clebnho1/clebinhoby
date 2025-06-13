-- Cria uma função para fazer upsert nas permissões do usuário
CREATE OR REPLACE FUNCTION public.upsert_user_permissions(
  p_user_id uuid,
  p_can_access_dashboard boolean DEFAULT false,
  p_can_access_whatsapp boolean DEFAULT false,
  p_can_access_ai_agents boolean DEFAULT false,
  p_can_access_colaboradores boolean DEFAULT false,
  p_can_access_configuracoes boolean DEFAULT false,
  p_can_access_administracao boolean DEFAULT false
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
    p_can_access_dashboard,
    p_can_access_whatsapp,
    p_can_access_ai_agents,
    p_can_access_colaboradores,
    p_can_access_configuracoes,
    p_can_access_administracao,
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
  
  RETURN result;
EXCEPTION
  WHEN others THEN
    RAISE EXCEPTION 'Erro ao atualizar permissões: %', SQLERRM;
END;
$$;

-- Garante que os usuários autenticados podem executar a função
GRANTANT EXECUTE ON FUNCTION public.upsert_user_permissions(
  uuid, boolean, boolean, boolean, boolean, boolean, boolean
) TO authenticated;

-- Comentários para documentação
COMMENT ON FUNCTION public.upsert_user_permissions IS 'Função para atualizar permissões de usuário com segurança';
COMMENT ON PARAMETER public.upsert_user_permissions.p_user_id IS 'ID do usuário cujas permissões serão atualizadas';
COMMENT ON PARAMETER public.upsert_user_permissions.p_can_access_dashboard IS 'Permite acesso ao dashboard';
COMMENT ON PARAMETER public.upsert_user_permissions.p_can_access_whatsapp IS 'Permite acesso ao módulo do WhatsApp';
COMMENT ON PARAMETER public.upsert_user_permissions.p_can_access_ai_agents IS 'Permite acesso aos agentes de IA';
COMMENT ON PARAMETER public.upsert_user_permissions.p_can_access_colaboradores IS 'Permite acesso ao gerenciamento de colaboradores';
COMMENT ON PARAMETER public.upsert_user_permissions.p_can_access_configuracoes IS 'Permite acesso às configurações do sistema';
COMMENT ON PARAMETER public.upsert_user_permissions.p_can_access_administracao IS 'Permite acesso à área administrativa';

-- Atualiza as políticas RLS para garantir que os usuários possam ver suas próprias permissões
DROP POLICY IF EXISTS "Enable read access for users' own permissions" ON public.user_permissions;
CREATE POLICY "Enable read access for users' own permissions" 
ON public.user_permissions
FOR SELECT
TO authenticated
USING (auth.uid() = user_id);

-- Permite que administradores vejam todas as permissões
DROP POLICY IF EXISTS "Enable all access for admins" ON public.user_permissions;
CREATE POLICY "Enable all access for admins" 
ON public.user_permissions
FOR ALL
TO authenticated
USING (
  EXISTS (
    SELECT 1 
    FROM auth.users 
    WHERE id = auth.uid() 
    AND raw_user_meta_data->>'role' = 'admin'
  )
);

-- Permite que os usuários atualizem suas próprias permissões
DROP POLICY IF EXISTS "Enable update for users' own permissions" ON public.user_permissions;
CREATE POLICY "Enable update for users' own permissions"
ON public.user_permissions
FOR UPDATE
TO authenticated
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- Permite que os usuários criem suas próprias permissões
DROP POLICY IF EXISTS "Enable insert for authenticated users" ON public.user_permissions;
CREATE POLICY "Enable insert for authenticated users"
ON public.user_permissions
FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = user_id);
