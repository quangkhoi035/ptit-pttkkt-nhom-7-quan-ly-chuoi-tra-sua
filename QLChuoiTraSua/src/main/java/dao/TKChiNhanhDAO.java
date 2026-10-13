package dao;

import java.sql.CallableStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import model.TKChiNhanh;

public class TKChiNhanhDAO extends DAO {

    /** Số đơn và doanh thu (đơn Hoàn thành) của từng chi nhánh, giảm dần theo doanh thu. */
    public List<TKChiNhanh> getTKChiNhanh(Date tuNgay, Date denNgay) {
        List<TKChiNhanh> kq = new ArrayList<>();
        try (CallableStatement cs = con.prepareCall("{call sp_ThongKeChiNhanh(?,?)}")) {
            cs.setDate(1, new java.sql.Date(tuNgay.getTime()));
            cs.setDate(2, new java.sql.Date(denNgay.getTime()));
            try (ResultSet rs = cs.executeQuery()) {
                while (rs.next()) {
                    TKChiNhanh tk = new TKChiNhanh();
                    tk.setId(rs.getInt("id"));
                    tk.setMa(rs.getString("ma"));
                    tk.setTen(rs.getString("ten"));
                    tk.setDiaChi(rs.getString("diaChi"));
                    tk.setSoDon(rs.getInt("soDon"));
                    tk.setDoanhThu(rs.getLong("doanhThu"));
                    tk.setTuNgay(tuNgay);
                    tk.setDenNgay(denNgay);
                    kq.add(tk);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return kq;
    }
}
