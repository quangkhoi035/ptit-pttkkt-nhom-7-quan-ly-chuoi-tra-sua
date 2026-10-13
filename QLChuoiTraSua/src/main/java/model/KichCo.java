package model;

import java.io.Serializable;

/** Kích cỡ ly: S, M, L. */
public class KichCo implements Serializable {

    private static final long serialVersionUID = 1L;

    private int id;
    private String ma;
    private String ten;

    public KichCo() {
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getMa() {
        return ma;
    }

    public void setMa(String ma) {
        this.ma = ma;
    }

    public String getTen() {
        return ten;
    }

    public void setTen(String ten) {
        this.ten = ten;
    }
}
