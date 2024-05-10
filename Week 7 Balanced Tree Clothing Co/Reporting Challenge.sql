-- Write a single SQL script that combines all of the previous questions into a scheduled report that the Balanced Tree team can run at the beginning of each month to calculate the previous month’s values.

-- Imagine that the Chief Financial Officer (which is also Danny) has asked for all of these questions at the end of every month.

-- He first wants you to generate the data for January only - but then he also wants you to demonstrate that you can easily run the samne analysis for February without many changes (if at all).

-- Feel free to split up your final outputs into as many tables as you need - but be sure to explicitly reference which table outputs relate to which question for full marks :

-- vIẾT MỘT SCRIP BAO GỒM TẤT CẢ CÁC CÂU HỎI TRONG MỘT BÁO CÁO ĐƯỢC LÊN LỊCH CÓ THỂ CHẠY VÀO MỖI ĐẦU THÁNG ĐỂ TÍNH GIẢ TRỊ THÁNG TRƯỚC 
-- TƯỞNG TƯỢNG RẰNG GIÁM ĐỐC TÀI CHÍNH ĐÃ HỎI TẤT CẢ CÁC CÂU HỎI VÀO MỖI CUỐI THÁNG
-- ANH ẤY MUỐN TẠO DỮ LIỆU CHỈ THÁNG 1 NHƯNG TIẾP THEO ANH ẤY CŨNG MUỐN BẠN CHỨNG MINH RẰNG BẠN CÓ THỂ DỄ DÀNG CHẠY PHÂN TÍCH CHO THÁNG 2 MÀ KHÔNG CẦN NHIỀU THAY ĐỔI
-- cÓ THỂ CHIA OUTPUT THÀNH NHIỀU BẢNG NẾU CẦN NHƯNG CHẮC CHẮN PHẢI CHỈ ĐỊNH RÕ RÀNG LÀ BẢNG KẾT QUẢ TƯƠNG ỨNG VỚI CÂU HỎI NÀO 

SELECT monthname(start_txn_time) AS month,
       SUM(qty) AS total_quantity,
       SUM(qty*price) AS revenue,
       SUM(qty*price*discount/100) AS net_revenue,
       COUNT(DISTINCT txn_id) AS num_txn
FROM sales
WHERE monthname(start_txn_time) = 'January'

WITH unique_prod AS (
SELECT txn_id,
       COUNT(prod_id) AS num_prod
FROM sales
GROUP BY txn_id
)
SELECT CAST(AVG(num_prod) AS DECIMAL(10,2)) AS avg_prod_per_txn
FROM unique_prod