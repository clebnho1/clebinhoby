-- Verifica se a tabela user_permissions existe e cria se não existir
CREATE TABLE IF NOT EXISTS public.user_permissions (
    id uuid NOT NULL DEFAULT gen_random_uuid(),
    user_id uuid NOT NULL,
    can_access_dashboard boolean DEFAULT true,
    can_access_whatsapp boolean DEFAULT true,
    can_access_ai_agents boolean DEFAULT true,
    can_access_colaboradores boolean DEFAULT true,
    can_access_configuracoes boolean DEFAULT true,
    can_access_administracao boolean DEFAULT false,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    CONSTRAINT user_permissions_pkey PRIMARY KEY (id),
    CONSTRAINT user_permissions_user_id_fkey FOREIGN KEY (user_id)
        REFERENCES auth.users (id) ON DELETE CASCADE
);

-- Cria um índice único para garantir que cada usuário tenha apenas um registro de permissão
CREATE UNIQUE INDEX IF NOT EXISTS user_permissions_user_id_key 
    ON public.user_permissions USING btree (user_id);

-- Função para atualizar o campo updated_at automaticamente
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
    RETURNS TRIGGER
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$;

-- Cria o trigger para atualizar o updated_at
DROP TRIGGER IF EXISTS update_user_permissions_updated_at ON public.user_permissions;
CREATE TRIGGER update_user_permissions_updated_at
    BEFORE UPDATE 
    ON public.user_permissions
    FOR EACH ROW
    EXECUTE FUNCTION public.update_updated_at_column();

-- Cria as políticas RLS
-- 1. Permite que usuários autenticados vejam apenas suas próprias permissões
CREATE POLICY "Enable read access for users' own permissions" 
    ON public.user_permissions
    FOR SELECT
    TO authenticated
    USING (auth.uid() = user_id);

-- 2. Permite que administradores façam qualquer operação
CREATE POLICY "Enable all access for admins" 
    ON public.user_permissions
    FOR ALL
    TO authenticated
    USING (EXISTS (
        SELECT 1 
        FROM auth.users 
        WHERE id = auth.uid() 
        AND raw_user_meta_data->>'role' = 'admin'
    ));

-- 3. Permite que usuários autenticados atualizem suas próprias permissões
CREATE POLICY "Enable update for users' own permissions"
    ON public.user_permissions
    FOR UPDATE
    TO authenticated
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- 4. Permite que usuários autenticados criem suas próprias permissões
CREATE POLICY "Enable insert for authenticated users"
    ON public.user_permissions
    FOR INSERT
    TO authenticated
    WITH CHECK (auth.uid() = user_id);

-- Ativa o RLS na tabela
ALTER TABLE public.user_permissions ENABLE ROW LEVEL SECURITY;

-- Garante permissões adequadas
GRANT ALL ON public.user_permissions TO anon, authenticated, service_role;
GRANT ALL ON SEQUENCE public.user_permissions_id_seq TO anon, authenticated, service_role;

-- Comentários para documentação
COMMENT ON TABLE public.user_permissions IS 'Armazena as permissões de acesso dos usuários';
COMMENT ON COLUMN public.user_permissions.user_id IS 'Referência ao usuário no auth.users';
COMMENT ON COLUMN public.user_permissions.can_access_dashboard IS 'Permite acesso ao dashboard principal';
COMMENT ON COLUMN public.user_permissions.can_access_whatsapp IS 'Permite acesso ao módulo do WhatsApp';
COMMENT ON COLUMN public.user_permissions.can_access_ai_agents IS 'Permite acesso aos agentes de IA';
COMMENT ON COLUMN public.user_permissions.can_access_colaboradores IS 'Permite acesso ao gerenciamento de colaboradores';
COMMENT ON COLUMN public.user_permissions.can_access_configuracoes IS 'Permite acesso às configurações do sistema';
COMMENT ON COLUMN public.user_permissions.can_access_administracao IS 'Permite acesso à área administrativa (apenas administradores)';

-- Cria uma função para obter as permissões do usuário atual
CREATE OR REPLACE FUNCTION public.get_user_permissions()
    RETURNS SETOF public.user_permissions
    LANGUAGE sql
    SECURITY DEFINER
    AS $$
    SELECT * FROM public.user_permissions 
    WHERE user_id = auth.uid()
    LIMIT 1;
$$;

-- Permite que usuários autenticados usem a função
GRANT EXECUTE ON FUNCTION public.get_user_permissions() TO authenticated;
