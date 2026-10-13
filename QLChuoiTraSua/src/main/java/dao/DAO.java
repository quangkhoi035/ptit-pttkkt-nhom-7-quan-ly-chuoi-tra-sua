package dao;

import java.io.InputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Properties;

/**
 * Lớp cơ sở của mọi DAO (Hình 3.3, 3.4): giữ kết nối JDBC {@code con}.
 * Mỗi DAO mở một kết nối khi khởi tạo; trang JSP dùng try-with-resources để đóng.
 */
public class DAO implements AutoCloseable {

    private static final Properties CFG = new Properties();

    static {
        try (InputStream in = DAO.class.getClassLoader().getResourceAsStream("db.properties")) {
            if (in == null) {
                throw new IllegalStateException("Không tìm thấy db.properties trong classpath");
            }
            CFG.load(new java.io.InputStreamReader(in, "UTF-8"));
            // Nạp driver JDBC (mặc định MySQL Connector/J; đổi db.driver nếu dùng driver khác)
            Class.forName(CFG.getProperty("db.driver", "com.mysql.cj.jdbc.Driver"));
        } catch (Exception e) {
            throw new ExceptionInInitializerError(e);
        }
    }

    protected Connection con;

    public DAO() {
        try {
            con = DriverManager.getConnection(CFG.getProperty("db.url"),
                    CFG.getProperty("db.user"), CFG.getProperty("db.password", ""));
        } catch (SQLException e) {
            throw new RuntimeException("Không kết nối được CSDL: " + e.getMessage(), e);
        }
    }

    @Override
    public void close() {
        try {
            if (con != null && !con.isClosed()) {
                con.close();
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}
