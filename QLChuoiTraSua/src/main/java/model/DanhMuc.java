package model;

import java.io.Serializable;

/** Danh mục sản phẩm. */
public class DanhMuc implements Serializable {

    private static final long serialVersionUID = 1L;

    private int id;
    private String ten;

    public DanhMuc() {
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getTen() {
        return ten;
    }

    public void setTen(String ten) {
        this.ten = ten;
    }
}
