package dao;

import java.sql.CallableStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;
import model.ThanhVien;

public class ThanhVienDAO extends DAO {

    /** Tìm thành viên theo SĐT; trả về null nếu chưa có. */
    public ThanhVien timTheoSDT(String sdt) {
        try (CallableStatement cs = con.prepareCall("{call sp_TimThanhVien(?)}")) {
            cs.setString(1, sdt);
            try (ResultSet rs = cs.executeQuery()) {
                if (rs.next()) {
                    ThanhVien tv = new ThanhVien();
                    tv.setId(rs.getInt("id"));
                    tv.setHoTen(rs.getString("hoTen"));
                    tv.setSdt(rs.getString("sdt"));
                    tv.setNgaySinh(rs.getDate("ngaySinh"));
                    tv.setDiemTichLuy(rs.getInt("diemTichLuy"));
                    tv.setNgayDangKy(rs.getTimestamp("ngayDangKy"));
                    return tv;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    /** Đăng ký nhanh; gán id mới cho {@code tv}. Trả về false nếu SĐT đã tồn tại hoặc lỗi. */
    public boolean themThanhVien(ThanhVien tv) {
        try (CallableStatement cs = con.prepareCall("{call sp_ThemThanhVien(?,?,?)}")) {
            cs.setString(1, tv.getHoTen());
            cs.setString(2, tv.getSdt());
            cs.registerOutParameter(3, Types.INTEGER);
            cs.execute();
            tv.setId(cs.getInt(3));
            tv.setDiemTichLuy(0);
            return true;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
}
