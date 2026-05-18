USE RikkeiClinicDB;
DROP PROCEDURE IF EXISTS TransferBed;

DELIMITER //

CREATE PROCEDURE TransferBed(
    IN p_patient_id INT,
    IN p_new_bed_id INT
)
BEGIN


    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    UPDATE Beds
    SET patient_id = NULL
    WHERE patient_id = p_patient_id;

    UPDATE Beds
    SET patient_id = p_patient_id
    WHERE bed_id = p_new_bed_id;

    COMMIT;

END //

DELIMITER ;

SELECT * FROM Beds;

CALL TransferBed(1, 201);

SELECT * FROM Beds;