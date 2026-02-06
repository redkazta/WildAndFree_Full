-- Agregar columna birthdate a profiles
ALTER TABLE public.profiles
ADD COLUMN IF NOT EXISTS birthdate DATE;
