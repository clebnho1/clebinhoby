-- 1. Primeiro, vamos verificar as políticas atuais
SELECT * FROM pg_policies 
WHERE tablename = 'user_permissions';

-- 2. Remover políticas existentes (se houver)
DROP POLICY IF EXISTS "Enable read access for users' own permissions" ON public.user_permissions;
DROP POLICY IF EXISTS "Enable all access for admins" ON public.user_permissions;
DROP POLICY IF EXISTS "Enable insert for authenticated users" ON public.user_permissions;

-- 3. Criar políticas RLS corretas
-- Política para usuários verem apenas suas próprias permissões
CREATE POLICY "Enable read access for users' own permissions" 
ON public.user_permissions
FOR SELECT
TO authenticated
USING (auth.uid() = user_id);

-- Política para administradores (ver todos)
CREATE POLICY "Enable all access for admins" 
ON public.user_permissions
FOR ALL
TO authenticated
USING (EXISTS (
  SELECT 1 FROM auth.users
  WHERE id = auth.uid() AND raw_user_meta_data->>'role' = 'admin'
));

-- Política para usuários autenticados inserirem/atualizarem suas próprias permissões
CREATE POLICY "Enable insert for authenticated users"
ON public.user_permissions
FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = user_id);

-- 4. Ativar RLS na tabela (caso não esteja ativado)
ALTER TABLE public.user_permissions ENABLE ROW LEVEL SECURITY;

-- 5. Garantir que a tabela permite acesso via API REST
GRANT ALL ON public.user_permissions TO anon, authenticated, service_role;
