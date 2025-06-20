-- 1. Primeiro, garante que a tabela existe com a estrutura correta
CREATE TABLE IF NOT EXISTS public.user_permissions (
  id bigint GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  can_access_dashboard boolean DEFAULT false,
  can_access_whatsapp boolean DEFAULT false,
  can_access_ai_agents boolean DEFAULT false,
  can_access_colaboradores boolean DEFAULT false,
  can_access_configuracoes boolean DEFAULT false,
  can_access_administracao boolean DEFAULT false,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  CONSTRAINT user_permissions_user_id_key UNIQUE (user_id)
);

-- 2. Remove todas as políticas existentes
DROP POLICY IF EXISTS "users_read_own_permissions" ON public.user_permissions;
DROP POLICY IF EXISTS "admins_full_access" ON public.user_permissions;
DROP POLICY IF EXISTS "users_update_own_permissions" ON public.user_permissions;
DROP POLICY IF EXISTS "users_insert_own_permissions" ON public.user_permissions;

-- 3. Habilita RLS na tabela
ALTER TABLE public.user_permissions ENABLE ROW LEVEL SECURITY;

-- 4. Cria políticas RLS simples para teste
-- Permite que todos os usuários autenticados vejam todas as permissões
CREATE POLICY "Allow all access to authenticated users" 
ON public.user_permissions
FOR ALL
TO authenticated
USING (true)
WITH CHECK (true);

-- 5. Concede permissões para os papéis apropriados
GRANT ALL ON TABLE public.user_permissions TO authenticated, service_role;
GRANT ALL ON SEQUENCE public.user_permissions_id_seq TO authenticated, service_role;

-- 6. Cria uma função para inserir/atualizar permissões
CREATE OR REPLACE FUNCTION public.upsert_user_permissions(
  p_user_id uuid,
  p_permissions jsonb
) 
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  -- Faz o upsert das permissões
  INSERT INTO public.user_permissions (
    user_id,
    can_access_dashboard,
    can_access_whatsapp,
    can_access_ai_agents,
    can_access_colaboradores,
    can_access_configuracoes,
    can_access_administracao
  )
  VALUES (
    p_user_id,
    COALESCE((p_permissions->>'can_access_dashboard')::boolean, false),
    COALESCE((p_permissions->>'can_access_whatsapp')::boolean, false),
    COALESCE((p_permissions->>'can_access_ai_agents')::boolean, false),
    COALESCE((p_permissions->>'can_access_colaboradores')::boolean, false),
    COALESCE((p_permissions->>'can_access_configuracoes')::boolean, false),
    COALESCE((p_permissions->>'can_access_administracao')::boolean, false)
  )
  ON CONFLICT (user_id) 
  DO UPDATE SET
    can_access_dashboard = EXCLUDED.can_access_dashboard,
    can_access_whatsapp = EXCLUDED.can_access_whatsapp,
    can_access_ai_agents = EXCLUDED.can_access_ai_agents,
    can_access_colaboradores = EXCLUDED.can_access_colaboradores,
    can_access_configuracoes = EXCLUDED.can_access_configuracoes,
    can_access_administracao = EXCLUDED.can_access_administracao,
    updated_at = now()
  RETURNING to_jsonb(public.user_permissions.*);
  
  RETURN jsonb_build_object('success', true);
EXCEPTION
  WHEN others THEN
    RETURN jsonb_build_object(
      'success', false,
      'error', SQLERRM,
      'state', SQLSTATE
    );
END;
$$;

-- 7. Concede permissão para executar a função
GRANT EXECUTE ON FUNCTION public.upsert_user_permissions(uuid, jsonb) TO authenticated, service_role;

-- 8. Cria uma função para obter permissões
CREATE OR REPLACE FUNCTION public.get_user_permissions(p_user_id uuid)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN (
    SELECT to_jsonb(up.*)
    FROM public.user_permissions up
    WHERE up.user_id = p_user_id
  );
END;
$$;

-- 9. Concede permissão para executar a função
GRANT EXECUTE ON FUNCTION public.get_user_permissions(uuid) TO authenticated, service_role;

-- 10. Cria um trigger para atualizar o updated_at
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 11. Cria o trigger se não existir
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_trigger
    WHERE tgname = 'on_user_permissions_updated'
  ) THEN
    CREATE TRIGGER on_user_permissions_updated
    BEFORE UPDATE ON public.user_permissions
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();
  END IF;
END
$$;
