package dao;

import java.sql.CallableStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import model.KhuyenMai;

public class KhuyenMaiDAO extends DAO {

    /** Trả về khuyến mãi còn hạn và còn lượt; null nếu mã không hợp lệ. */
    public KhuyenMai kiemTraMa(String maCode) {
        try (CallableStatement cs = con.prepareCall("{call sp_KiemTraKhuyenMai(?)}")) {
            cs.setString(1, maCode);
            try (ResultSet rs = cs.executeQuery()) {
                if (rs.next()) {
                    KhuyenMai km = new KhuyenMai();
                    km.setId(rs.getInt("id"));
                    km.setMaCode(rs.getString("maCode"));
                    km.setTenKM(rs.getString("tenKM"));
                    km.setLoaiGiam(rs.getString("loaiGiam"));
                    km.setGiaTriGiam(rs.getLong("giaTriGiam"));
                    long toiDa = rs.getLong("giamToiDa");
                    km.setGiamToiDa(rs.wasNull() ? null : toiDa);
                    km.setDonToiThieu(rs.getLong("donToiThieu"));
                    km.setNgayBatDau(rs.getTimestamp("ngayBatDau"));
                    km.setNgayKetThuc(rs.getTimestamp("ngayKetThuc"));
                    km.setSoLuotConLai(rs.getInt("soLuotConLai"));
                    return km;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }
}
