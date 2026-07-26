-- =====================================================
-- Functions for token operations
-- =====================================================

-- Decrement user token balance
CREATE OR REPLACE FUNCTION public.decrement_tokens(p_user_id UUID, p_amount INTEGER)
RETURNS INTEGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_balance INTEGER;
BEGIN
  UPDATE public.user_tokens
  SET balance = GREATEST(balance - p_amount, 0),
      updated_at = NOW()
  WHERE user_id = p_user_id
  RETURNING balance INTO v_balance;

  RETURN v_balance;
END;
$$;

-- Get user's token balance
CREATE OR REPLACE FUNCTION public.get_token_balance(p_user_id UUID)
RETURNS INTEGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_balance INTEGER;
BEGIN
  SELECT balance INTO v_balance
  FROM public.user_tokens
  WHERE user_id = p_user_id;

  RETURN COALESCE(v_balance, 0);
END;
$$;

-- Grant execute permissions
GRANT EXECUTE ON FUNCTION public.decrement_tokens TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_token_balance TO authenticated;
