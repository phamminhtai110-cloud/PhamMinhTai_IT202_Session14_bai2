# PhamMinhTai_IT202_Session14_bai2

# [Vận dụng nâng cao] Kiểm soát giao dịch cấp phát thuốc

```sql
USE RikkeiClinicDB;

DROP PROCEDURE IF EXISTS DispenseMedicine;

DELIMITER //

CREATE PROCEDURE DispenseMedicine(
    IN p_patient_id INT,
    IN p_medicine_id INT,
    IN p_quantity INT,
    OUT p_message VARCHAR(255)
)
BEGIN

    DECLARE v_stock INT;
    DECLARE v_price DECIMAL(18,2);
    DECLARE v_total_cost DECIMAL(18,2);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_message = 'Loi: He thong gap su co';
    END;

    START TRANSACTION;

    SELECT stock, price
    INTO v_stock, v_price
    FROM Medicines
    WHERE medicine_id = p_medicine_id;

    IF v_stock < p_quantity THEN

        ROLLBACK;

        SET p_message = 'Loi: So luong ton kho khong du';

    ELSE

        SET v_total_cost = v_price * p_quantity;

        UPDATE Medicines
        SET stock = stock - p_quantity
        WHERE medicine_id = p_medicine_id;

        UPDATE Patient_Invoices
        SET total_due = total_due + v_total_cost
        WHERE patient_id = p_patient_id;

        COMMIT;

        SET p_message = 'Da cap phat thanh cong';

    END IF;

END //

DELIMITER ;

SELECT * FROM Medicines;

SELECT * FROM Patient_Invoices;

SET @message = '';

CALL DispenseMedicine(1, 1, 10, @message);

SELECT @message AS Result;

SELECT * FROM Medicines WHERE medicine_id = 1;

SELECT * FROM Patient_Invoices WHERE patient_id = 1;

SET @message = '';

CALL DispenseMedicine(1, 2, 10, @message);

SELECT @message AS Result;

SELECT * FROM Medicines WHERE medicine_id = 2;

SELECT * FROM Patient_Invoices WHERE patient_id = 1;
