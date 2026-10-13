package dao;

import java.sql.CallableStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import model.ChiNhanh;
import model.NhanVien;
import util.MatKhau;

public class NhanVienDAO extends DAO {

    /**
     * Kiểm tra đăng nhập. Nếu đúng, nạp thêm họ tên, chức vụ, chi nhánh vào {@code nv}.
     * Mật khẩu được băm SHA-256 trước khi so khớp với CSDL.
     */
    public boolean checkLogin(NhanVien nv) {
        try (CallableStatement cs = con.prepareCall("{call sp_DangNhap(?,?)}")) {
            cs.setString(1, nv.getTenDangNhap());
            cs.setString(2, MatKhau.bam(nv.getMatKhau()));
            try (ResultSet rs = cs.executeQuery()) {
                if (!rs.next()) {
                    return false;
                }
                nv.setIdNhanVien(rs.getInt("id"));
                nv.setMaNV(rs.getString("maNV"));
                nv.setChucVu(rs.getString("chucVu"));
                nv.setId(rs.getInt("idNguoiDung"));
                nv.setHoTen(rs.getString("hoTen"));
                nv.setSdt(rs.getString("sdt"));
                nv.setEmail(rs.getString("email"));
                nv.setNgaySinh(rs.getDate("ngaySinh"));
                nv.setMatKhau(null);
                int idCN = rs.getInt("idChiNhanh");
                if (!rs.wasNull()) {
                    ChiNhanh cn = new ChiNhanh();
                    cn.setId(idCN);
                    cn.setMa(rs.getString("maCN"));
                    cn.setTen(rs.getString("tenCN"));
                    cn.setDiaChi(rs.getString("diaChiCN"));
                    nv.setChiNhanh(cn);
                }
                return true;
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
}
