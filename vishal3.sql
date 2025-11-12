use event_management_system;
DROP PROCEDURE IF EXISTS register_user;
DELIMITER $$

CREATE PROCEDURE register_user(IN p_user_id INT, IN p_event_id INT)
BEGIN
    DECLARE v_capacity INT;
    DECLARE v_count INT;
    DECLARE v_duplicate INT;

    -- Check if user exists
    SELECT COUNT(*) INTO v_count 
    FROM users 
    WHERE user_id = p_user_id;

    IF v_count = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'User not found';
    END IF;

    -- Check if event exists and get capacity
    SELECT capacity INTO v_capacity 
    FROM events 
    WHERE event_id = p_event_id;

    IF v_capacity IS NULL THEN
        SET v_capacity = NULL; -- unlimited
    END IF;

    -- Check for duplicate registration
    SELECT COUNT(*) INTO v_duplicate 
    FROM registrations 
    WHERE user_id = p_user_id AND event_id = p_event_id;

    IF v_duplicate > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Already registered for this event';
    END IF;

    -- Check capacity limit
    IF v_capacity IS NOT NULL THEN
        SELECT COUNT(*) INTO v_count 
        FROM registrations 
        WHERE event_id = p_event_id;  -- simple COUNT, no group by needed
        IF v_count >= v_capacity THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Event is full';
        END IF;
    END IF;

    -- Insert registration
    INSERT INTO registrations (user_id, event_id)
    VALUES (p_user_id, p_event_id);
END$$

DELIMITER ;
CALL register_user(1, 1);
SELECT * FROM registrations;




