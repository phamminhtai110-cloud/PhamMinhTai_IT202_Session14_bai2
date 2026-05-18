# PhamMinhTai_IT202_Session14_bai2

# [Vận dụng nâng cao] Kiểm soát giao dịch cấp phát thuốc

## 1. Phân tích yêu cầu

### Dữ liệu đầu vào
- `p_patient_id` : Mã bệnh nhân
- `p_medicine_id` : Mã thuốc
- `p_quantity` : Số lượng cấp phát

### Dữ liệu đầu ra
- `p_message` : Thông báo trạng thái xử lý

### Loại tham số phù hợp
- `IN` : dùng để nhận dữ liệu đầu vào
- `OUT` : dùng để trả về thông báo trạng thái

---

# 2. Giải pháp xử lý

Hệ thống cần sử dụng `Transaction` để đảm bảo:

- Nếu cấp phát hợp lệ:
  - Trừ kho thuốc
  - Cộng công nợ
  - `COMMIT`

- Nếu tồn kho không đủ:
  - Không cập nhật dữ liệu
  - `ROLLBACK`
  - Trả thông báo lỗi

---

# 3. Các bước thực hiện

### Bước 1
Kiểm tra số lượng tồn kho và giá thuốc.

### Bước 2
So sánh tồn kho với số lượng yêu cầu.

### Bước 3
Nếu không đủ:
- Rollback
- Trả thông báo:
  - `Loi: So luong ton kho khong du`

### Bước 4
Nếu đủ:
- Trừ tồn kho
- Tính tổng tiền thuốc
- Cộng công nợ bệnh nhân
- Commit transaction
- Trả thông báo:
  - `Da cap phat thanh cong`

---

# 4. Triển khai mã nguồn

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
