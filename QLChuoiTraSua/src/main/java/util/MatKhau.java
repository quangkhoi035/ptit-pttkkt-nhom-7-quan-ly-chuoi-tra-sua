package util;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

/** Băm mật khẩu SHA-256 (hex) trước khi so khớp với CSDL. */
public final class MatKhau {

    private MatKhau() {
    }

    public static String bam(String matKhau) {
        if (matKhau == null) {
            return "";
        }
        try {
            byte[] h = MessageDigest.getInstance("SHA-256").digest(matKhau.getBytes(StandardCharsets.UTF_8));
            StringBuilder sb = new StringBuilder();
            for (byte b : h) {
                sb.append(String.format("%02x", b));
            }
            return sb.toString();
        } catch (NoSuchAlgorithmException e) {
            throw new IllegalStateException(e);
        }
    }
}
