CREATE OR REPLACE FUNCTION validate_user_credentials()
RETURNS trigger AS $$
BEGIN
    IF NEW.email !~ '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$' THEN
        RAISE EXCEPTION 'Invalid email format: %', NEW.email;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER trigger_validate_user_credentials
BEFORE INSERT ON "Users"
FOR EACH ROW
EXECUTE FUNCTION validate_user_credentials();
