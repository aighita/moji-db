CREATE OR REPLACE TRIGGER trg_users_soft_delete
BEFORE UPDATE ON USERS
FOR EACH ROW
BEGIN
    IF :NEW.status = 'deleted' AND :OLD.status != 'deleted' THEN
        :NEW.deleted_at := SYSTIMESTAMP;
    ELSIF :NEW.status != 'deleted' THEN
        :NEW.deleted_at := NULL;
    END IF;
END;
/
