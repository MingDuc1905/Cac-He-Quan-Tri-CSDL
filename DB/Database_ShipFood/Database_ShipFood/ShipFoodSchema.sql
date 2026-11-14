-- DROP USER SHIPFOOD;

CREATE USER SHIPFOOD
-- IDENTIFIED BY <password>
;

CREATE OR REPLACE TYPE SHIPFOOD.t_bien_the AS OBJECT (
    tensize     VARCHAR2(10),
    giatien     NUMBER(15,2)
);

CREATE OR REPLACE TYPE SHIPFOOD.t_bien_the_list AS TABLE OF t_bien_the;

CREATE OR REPLACE TYPE SHIPFOOD.t_chi_tiet_don AS OBJECT (
    mamon_bienthe   NUMBER(10),   -- id của tbBienTheMonAn
    soluong         NUMBER(10),
    dongia          NUMBER(15,2)
);

CREATE OR REPLACE TYPE SHIPFOOD.t_chi_tiet_don_list AS TABLE OF t_chi_tiet_don;

CREATE OR REPLACE FORCE EDITIONABLE JSON RELATIONAL DUALITY VIEW "SHIPFOOD"."DV_DON_HANG"  AS 
  SELECT JSON {
    '_id'          : d.madh,
    'ngaydathang'  : d.ngaydathang,
    'trangthai'    : d.trangthai,
    'tongtien'     : d.tongtien,
    'phiship'      : d.phiship,
    'phidichvu'    : d.phidichvu,
    'ghichu'       : d.ghichu,
    'ngaygiaohang' : d.ngaygiaohang,
    'ngaythanhtoan': d.ngaythanhtoan,
    'momoTransId'  : d.momo_trans_id,
    'quanAn'       : (SELECT JSON {'userid' : q.userid, 'tenquanan' : q.tenquanan, 'diachi' : q.diachi}
                      FROM tbQuanAn q WITH NOINSERT NOUPDATE NODELETE
                      WHERE q.userid = d.maquan),
    'giaoHang'     : (SELECT JSON {'mattdh' : t.mattdh, 'tennguoinhan' : t.tennguoinhan,
                                   'sdt' : t.sdt, 'diachi' : t.diachi, 'toado' : t.toado,
                                   'userid' : t.userid}
                      FROM tbThongTinDatHang t WITH NOINSERT NOUPDATE NODELETE
                      WHERE t.mattdh = d.mattdh),
    'thanhToan'    : (SELECT JSON {'mahttt' : l.mahttt, 'tenhinhthuc' : l.tenhinhthuc}
                      FROM tbLoaiHinhThanhToan l WITH NOINSERT NOUPDATE NODELETE
                      WHERE l.mahttt = d.hinhthucthanhtoan),
    'shipper'      : (SELECT JSON {'userid' : s.userid, 'tenshipper' : s.tenshipper}
                      FROM tbShipper s WITH NOINSERT NOUPDATE NODELETE
                      WHERE s.userid = d.mashipper),
    'khuyenMai'    : (SELECT JSON {'makm' : k.makm, 'tenkm' : k.tenkm, 'phantramgiam' : k.phantramgiam}
                      FROM tbKhuyenMai k WITH NOINSERT NOUPDATE NODELETE
                      WHERE k.makm = d.makhuyenmai),
    'chiTiet'      : [ SELECT JSON {
                          'mactdh'  : c.mactdh,
                          'soluong' : c.soluong,
                          'dongia'  : c.dongia,
                          'bienThe' : (SELECT JSON {
                                          'id' : b.id, 'tensize' : b.tensize, 'giatien' : b.giatien,
                                          'monAn' : (SELECT JSON {'mamon' : m.mamon, 'tenmon' : m.tenmon,
                                                                  'hinhanh' : m.hinhanh}
                                                     FROM tbMonAn m WITH NOINSERT NOUPDATE NODELETE
                                                     WHERE m.mamon = b.mamon)}
                                       FROM tbBienTheMonAn b WITH NOINSERT NOUPDATE NODELETE
                                       WHERE b.id = c.mamon),
                          'danhGia' : [ SELECT JSON {
                                           'madg' : g.madg, 'diemdanhgia' : g.diemdanhgia,
                                           'nhanxet' : g.nhanxet, 'hinhanh' : g.hinhanh,
                                           'ngaydanhgia' : g.ngaydanhgia,
                                           'phanHoiCuaQuan' : g.phanHoiCuaQuan}
                                        FROM tbDanhGia g WITH INSERT UPDATE DELETE
                                        WHERE g.mactdh = c.mactdh ]
                       }
                       FROM tbChiTietDonHang c WITH INSERT UPDATE DELETE
                       WHERE c.madh = d.madh ]
}
FROM tbDonHang d WITH INSERT UPDATE NODELETE;
;

CREATE OR REPLACE FORCE EDITIONABLE JSON RELATIONAL DUALITY VIEW "SHIPFOOD"."DV_KHACH_HANG"  AS 
  SELECT JSON {
    '_id'      : k.userid,
    'tenkh'    : k.tenkh,
    'hinhanh'  : k.hinhanh,
    'taiKhoan' : (SELECT JSON {
                       'userid'    : u.userid, -- BỔ SUNG CỘT LIÊN KẾT TẠI ĐÂY
                       'username'  : u.username, 
                       'email'     : u.email,
                       'sdt'       : u.sdt, 
                       'trangthai' : u.trangthai
                  }
                  FROM tbUser u WITH NOINSERT UPDATE NODELETE
                  WHERE u.userid = k.userid),
    'diaChi'   : [ SELECT JSON {
                        'mattdh'       : t.mattdh, 
                        'tennguoinhan' : t.tennguoinhan,
                        'sdt'          : t.sdt, 
                        'diachi'       : t.diachi, 
                        'toado'        : t.toado
                   }
                   FROM tbThongTinDatHang t WITH INSERT UPDATE DELETE
                   WHERE t.userid = k.userid ]
}
FROM tbKhachHang k WITH NOINSERT UPDATE NODELETE;
;

CREATE OR REPLACE FORCE EDITIONABLE JSON RELATIONAL DUALITY VIEW "SHIPFOOD"."DV_KHUYEN_MAI"  AS 
  SELECT JSON {
    '_id'          : k.makm,
    'tenkm'        : k.tenkm,
    'mota'         : k.mota,
    'loaikm'       : k.loaikm,
    'phantramgiam' : k.phantramgiam,
    'dieukien'     : k.dieukien,
    'ngaybatdau'   : k.ngaybatdau,
    'ngayketthuc'  : k.ngayketthuc,
    'monApDung'    : [ SELECT JSON {'id' : mk.id, 'mabienthe' : mk.mamon,
                                    'phantramgiam' : mk.phantramgiam,
                                    'soluong' : mk.soluong, 'trangthai' : mk.trangthai}
                       FROM tbMonAnKhuyenMai mk WITH INSERT UPDATE DELETE
                       WHERE mk.makm = k.makm ]
}
FROM tbKhuyenMai k WITH INSERT UPDATE DELETE;
;

CREATE OR REPLACE FORCE EDITIONABLE JSON RELATIONAL DUALITY VIEW "SHIPFOOD"."DV_MON_AN"  AS 
  SELECT JSON {
    '_id'       : m.mamon,
    'tenmon'    : m.tenmon,
    'mota'      : m.mota,
    'hinhanh'   : m.hinhanh,
    'conhang'   : m.conhang,
    'isDeleted' : m.isDeleted,
    'quanAn'    : (SELECT JSON {'userid' : q.userid, 'tenquanan' : q.tenquanan}
                   FROM tbQuanAn q WITH NOINSERT NOUPDATE NODELETE
                   WHERE q.userid = m.maquanan),
    'danhMuc'   : (SELECT JSON {'madanhmuc' : dm.madanhmuc, 'tendanhmuc' : dm.tendanhmuc}
                   FROM tbDanhMuc dm WITH NOINSERT NOUPDATE NODELETE
                   WHERE dm.madanhmuc = m.madanhmuc),
    'bienThe'   : [ SELECT JSON {
                       'id' : b.id, 'tensize' : b.tensize, 'giatien' : b.giatien,
                       'khuyenMai' : [ SELECT JSON {
                                          'id' : mk.id, 'makm' : mk.makm,
                                          'phantramgiam' : mk.phantramgiam,
                                          'soluong' : mk.soluong, 'trangthai' : mk.trangthai}
                                       FROM tbMonAnKhuyenMai mk WITH INSERT UPDATE DELETE
                                       WHERE mk.mamon = b.id ]
                    }
                    FROM tbBienTheMonAn b WITH INSERT UPDATE DELETE
                    WHERE b.mamon = m.mamon ]
}
FROM tbMonAn m WITH INSERT UPDATE NODELETE;
;

CREATE OR REPLACE FORCE EDITIONABLE JSON RELATIONAL DUALITY VIEW "SHIPFOOD"."DV_QUAN_AN"  AS 
  SELECT JSON {
    '_id'           : q.userid,
    'tenquanan'     : q.tenquanan,
    'diachi'        : q.diachi,
    'toado'         : q.toado,
    'diemdanhgia'   : q.diemdanhgia,
    'soluotdanhgia' : q.soluotdanhgia,
    'trangthai'     : q.trangthai,
    'hinhanh'       : q.hinhanh,
    'taiKhoan'      : (SELECT JSON {
                            'userid'    : u.userid, -- BỔ SUNG CỘT LIÊN KẾT Ở ĐÂY
                            'username'  : u.username, 
                            'email'     : u.email,
                            'sdt'       : u.sdt, 
                            'trangthai' : u.trangthai
                       }
                       FROM tbUser u WITH NOINSERT UPDATE NODELETE
                       WHERE u.userid = q.userid),
    'thucDon'       : [ SELECT JSON {
                            'mamon'     : m.mamon, 
                            'tenmon'    : m.tenmon,
                            'conhang'   : m.conhang, 
                            'isDeleted' : m.isDeleted
                        }
                        FROM tbMonAn m WITH NOINSERT UPDATE NODELETE
                        WHERE m.maquanan = q.userid ]
}
FROM tbQuanAn q WITH NOINSERT UPDATE NODELETE;
;

-- DDL generated by DBeaver
-- WARNING: It may differ from actual native database DDL

-- Drop table

-- DROP TABLE SHIPFOOD.TBADMIN;

CREATE TABLE SHIPFOOD.TBADMIN (
	USERID NUMBER(10,0),
	TENADMIN VARCHAR2(50),
	HINHANH VARCHAR2(500),
	CONSTRAINT PK_TBADMIN PRIMARY KEY (USERID),
	CONSTRAINT SYS_C008904 CHECK ("USERID" IS NOT NULL),
	CONSTRAINT SYS_C008905 CHECK ("TENADMIN" IS NOT NULL),
	CONSTRAINT FK_TBADMIN_USER FOREIGN KEY (USERID) REFERENCES SHIPFOOD.TBUSER(USERID)
);
CREATE UNIQUE INDEX PK_TBADMIN ON SHIPFOOD.TBADMIN (USERID);
;

-- DDL generated by DBeaver
-- WARNING: It may differ from actual native database DDL

-- Drop table

-- DROP TABLE SHIPFOOD.TBBIENTHEMONAN;

CREATE TABLE SHIPFOOD.TBBIENTHEMONAN (
	ID NUMBER(10,0) DEFAULT "SHIPFOOD"."ISEQ$$_73514".nextval,
	MAMON NUMBER(10,0),
	TENSIZE VARCHAR2(10),
	GIATIEN NUMBER(15,2),
	CONSTRAINT CK_TBBIENTHE_GIA CHECK (giatien >= 0),
	CONSTRAINT PK_TBBIENTHEMONAN PRIMARY KEY (ID),
	CONSTRAINT SYS_C008936 CHECK ("ID" IS NOT NULL),
	CONSTRAINT SYS_C008937 CHECK ("MAMON" IS NOT NULL),
	CONSTRAINT UQ_TBBIENTHE_MON_SIZE UNIQUE (MAMON,TENSIZE),
	CONSTRAINT FK_TBBIENTHE_MON FOREIGN KEY (MAMON) REFERENCES SHIPFOOD.TBMONAN(MAMON) ON DELETE CASCADE
);
CREATE INDEX IX_TBBIENTHE_MON ON SHIPFOOD.TBBIENTHEMONAN (MAMON);
CREATE UNIQUE INDEX PK_TBBIENTHEMONAN ON SHIPFOOD.TBBIENTHEMONAN (ID);
CREATE UNIQUE INDEX UQ_TBBIENTHE_MON_SIZE ON SHIPFOOD.TBBIENTHEMONAN (MAMON,TENSIZE);
;

-- DDL generated by DBeaver
-- WARNING: It may differ from actual native database DDL

-- Drop table

-- DROP TABLE SHIPFOOD.TBCHITIETDONHANG;

CREATE TABLE SHIPFOOD.TBCHITIETDONHANG (
	MACTDH NUMBER(10,0) DEFAULT "SHIPFOOD"."ISEQ$$_73543".nextval,
	MADH NUMBER(10,0),
	MAMON NUMBER(10,0),
	SOLUONG NUMBER(10,0) DEFAULT 1 ,
	DONGIA NUMBER(15,2),
	CONSTRAINT CK_TBCTDH_SL CHECK (soluong BETWEEN 1 AND 20),
	CONSTRAINT PK_TBCTDH PRIMARY KEY (MACTDH),
	CONSTRAINT SYS_C008977 CHECK ("MACTDH" IS NOT NULL),
	CONSTRAINT SYS_C008978 CHECK ("MADH" IS NOT NULL),
	CONSTRAINT SYS_C008979 CHECK ("MAMON" IS NOT NULL),
	CONSTRAINT SYS_C008980 CHECK ("SOLUONG" IS NOT NULL),
	CONSTRAINT FK_TBCTDH_BT FOREIGN KEY (MAMON) REFERENCES SHIPFOOD.TBBIENTHEMONAN(ID),
	CONSTRAINT FK_TBCTDH_DH FOREIGN KEY (MADH) REFERENCES SHIPFOOD.TBDONHANG(MADH) ON DELETE CASCADE
);
CREATE INDEX IX_TBCTDH_BT ON SHIPFOOD.TBCHITIETDONHANG (MAMON);
CREATE INDEX IX_TBCTDH_DH ON SHIPFOOD.TBCHITIETDONHANG (MADH);
CREATE UNIQUE INDEX PK_TBCTDH ON SHIPFOOD.TBCHITIETDONHANG (MACTDH);
;

-- DDL generated by DBeaver
-- WARNING: It may differ from actual native database DDL

-- Drop table

-- DROP TABLE SHIPFOOD.TBDANHGIA;

CREATE TABLE SHIPFOOD.TBDANHGIA (
	MADG NUMBER(10,0) DEFAULT "SHIPFOOD"."ISEQ$$_73548".nextval,
	MACTDH NUMBER(10,0),
	DIEMDANHGIA NUMBER(1,0),
	NHANXET VARCHAR2(500),
	HINHANH VARCHAR2(500),
	NGAYDANHGIA TIMESTAMP DEFAULT SYSTIMESTAMP,
	PHANHOICUAQUAN VARCHAR2(500),
	CONSTRAINT CK_TBDANHGIA_DIEM CHECK (diemdanhgia BETWEEN 1 AND 5),
	CONSTRAINT PK_TBDANHGIA PRIMARY KEY (MADG),
	CONSTRAINT SYS_C008985 CHECK ("MADG" IS NOT NULL),
	CONSTRAINT FK_TBDANHGIA_CTDH FOREIGN KEY (MACTDH) REFERENCES SHIPFOOD.TBCHITIETDONHANG(MACTDH) ON DELETE CASCADE
);
CREATE INDEX IX_TBDANHGIA_CTDH ON SHIPFOOD.TBDANHGIA (MACTDH);
CREATE UNIQUE INDEX PK_TBDANHGIA ON SHIPFOOD.TBDANHGIA (MADG);
;

-- DDL generated by DBeaver
-- WARNING: It may differ from actual native database DDL

-- Drop table

-- DROP TABLE SHIPFOOD.TBDANHMUC;

CREATE TABLE SHIPFOOD.TBDANHMUC (
	MADANHMUC NUMBER(10,0) DEFAULT "SHIPFOOD"."ISEQ$$_73506".nextval,
	TENDANHMUC VARCHAR2(100),
	MOTA VARCHAR2(250),
	HINHANH VARCHAR2(500),
	ICON VARCHAR2(50),
	CONSTRAINT PK_TBDANHMUC PRIMARY KEY (MADANHMUC),
	CONSTRAINT SYS_C008926 CHECK ("MADANHMUC" IS NOT NULL),
	CONSTRAINT SYS_C008927 CHECK ("TENDANHMUC" IS NOT NULL)
);
CREATE UNIQUE INDEX PK_TBDANHMUC ON SHIPFOOD.TBDANHMUC (MADANHMUC);
;

-- DDL generated by DBeaver
-- WARNING: It may differ from actual native database DDL

-- Drop table

-- DROP TABLE SHIPFOOD.TBDONHANG;

CREATE TABLE SHIPFOOD.TBDONHANG (
	MADH NUMBER(10,0) DEFAULT "SHIPFOOD"."ISEQ$$_73535".nextval,
	MAQUAN NUMBER(10,0),
	MATTDH NUMBER(10,0),
	NGAYDATHANG TIMESTAMP DEFAULT SYSTIMESTAMP ,
	TRANGTHAI VARCHAR2(50),
	TONGTIEN NUMBER(15,2),
	HINHTHUCTHANHTOAN NUMBER(10,0),
	GHICHU VARCHAR2(200),
	MAKHUYENMAI NUMBER(10,0),
	PHISHIP NUMBER(15,2),
	PHIDICHVU NUMBER(15,2),
	NGAYGIAOHANG TIMESTAMP,
	NGAYTHANHTOAN TIMESTAMP,
	MASHIPPER NUMBER(10,0),
	MOMO_TRANS_ID VARCHAR2(100),
	CONSTRAINT CK_TBDH_TIEN CHECK (tongtien >= 0 AND phiship >= 0 AND phidichvu >= 0),
	CONSTRAINT PK_TBDONHANG PRIMARY KEY (MADH),
	CONSTRAINT SYS_C008966 CHECK ("MADH" IS NOT NULL),
	CONSTRAINT SYS_C008967 CHECK ("MAQUAN" IS NOT NULL),
	CONSTRAINT SYS_C008968 CHECK ("MATTDH" IS NOT NULL),
	CONSTRAINT SYS_C008969 CHECK ("NGAYDATHANG" IS NOT NULL),
	CONSTRAINT FK_TBDH_HTTT FOREIGN KEY (HINHTHUCTHANHTOAN) REFERENCES SHIPFOOD.TBLOAIHINHTHANHTOAN(MAHTTT),
	CONSTRAINT FK_TBDH_KM FOREIGN KEY (MAKHUYENMAI) REFERENCES SHIPFOOD.TBKHUYENMAI(MAKM),
	CONSTRAINT FK_TBDH_QUAN FOREIGN KEY (MAQUAN) REFERENCES SHIPFOOD.TBQUANAN(USERID),
	CONSTRAINT FK_TBDH_SHIPPER FOREIGN KEY (MASHIPPER) REFERENCES SHIPFOOD.TBSHIPPER(USERID),
	CONSTRAINT FK_TBDH_TTDH FOREIGN KEY (MATTDH) REFERENCES SHIPFOOD.TBTHONGTINDATHANG(MATTDH)
);
CREATE INDEX IX_TBDH_KM ON SHIPFOOD.TBDONHANG (MAKHUYENMAI);
CREATE INDEX IX_TBDH_QUAN_TT ON SHIPFOOD.TBDONHANG (MAQUAN,TRANGTHAI);
CREATE INDEX IX_TBDH_SHIPPER ON SHIPFOOD.TBDONHANG (MASHIPPER);
CREATE INDEX IX_TBDH_TTDH ON SHIPFOOD.TBDONHANG (MATTDH);
CREATE INDEX IX_TBDH_TT_NGAY ON SHIPFOOD.TBDONHANG (TRANGTHAI,NGAYDATHANG);
CREATE UNIQUE INDEX PK_TBDONHANG ON SHIPFOOD.TBDONHANG (MADH);
;

-- DDL generated by DBeaver
-- WARNING: It may differ from actual native database DDL

-- Drop table

-- DROP TABLE SHIPFOOD.TBEINVOICE;

CREATE TABLE SHIPFOOD.TBEINVOICE (
	EINVOICE_ID NUMBER(10,0) DEFAULT "SHIPFOOD"."ISEQ$$_73556".nextval,
	INVOICE_NUMBER VARCHAR2(50),
	MADH NUMBER(10,0),
	NGAYXUAT TIMESTAMP DEFAULT SYSTIMESTAMP ,
	TONGTIEN NUMBER(15,2),
	IS_DIGITAL_SIGNED BOOLEAN DEFAULT FALSE ,
	QR_CODE_DATA VARCHAR2(2000),
	LOAICHUNGTU VARCHAR2(20) DEFAULT 'EInvoice' ,
	CONSTRAINT CK_TBEINVOICE_LOAI CHECK (loaichungtu IN ('EInvoice','EWaybill')),
	CONSTRAINT PK_TBEINVOICE PRIMARY KEY (EINVOICE_ID),
	CONSTRAINT SYS_C008994 CHECK ("EINVOICE_ID" IS NOT NULL),
	CONSTRAINT SYS_C008995 CHECK ("INVOICE_NUMBER" IS NOT NULL),
	CONSTRAINT SYS_C008996 CHECK ("MADH" IS NOT NULL),
	CONSTRAINT SYS_C008997 CHECK ("NGAYXUAT" IS NOT NULL),
	CONSTRAINT SYS_C008998 CHECK ("TONGTIEN" IS NOT NULL),
	CONSTRAINT SYS_C008999 CHECK ("IS_DIGITAL_SIGNED" IS NOT NULL),
	CONSTRAINT SYS_C009000 CHECK ("LOAICHUNGTU" IS NOT NULL),
	CONSTRAINT UQ_TBEINVOICE_SO UNIQUE (INVOICE_NUMBER),
	CONSTRAINT FK_TBEINVOICE_DH FOREIGN KEY (MADH) REFERENCES SHIPFOOD.TBDONHANG(MADH)
);
CREATE INDEX IX_TBEINVOICE_DH ON SHIPFOOD.TBEINVOICE (MADH);
CREATE UNIQUE INDEX PK_TBEINVOICE ON SHIPFOOD.TBEINVOICE (EINVOICE_ID);
CREATE UNIQUE INDEX UQ_TBEINVOICE_SO ON SHIPFOOD.TBEINVOICE (INVOICE_NUMBER);
;

-- DDL generated by DBeaver
-- WARNING: It may differ from actual native database DDL

-- Drop table

-- DROP TABLE SHIPFOOD.TBKHACHHANG;

CREATE TABLE SHIPFOOD.TBKHACHHANG (
	USERID NUMBER(10,0),
	TENKH VARCHAR2(50),
	HINHANH VARCHAR2(500),
	CONSTRAINT PK_TBKHACHHANG PRIMARY KEY (USERID),
	CONSTRAINT SYS_C008908 CHECK ("USERID" IS NOT NULL),
	CONSTRAINT SYS_C008909 CHECK ("TENKH" IS NOT NULL),
	CONSTRAINT FK_TBKHACHHANG_USER FOREIGN KEY (USERID) REFERENCES SHIPFOOD.TBUSER(USERID)
);
CREATE UNIQUE INDEX PK_TBKHACHHANG ON SHIPFOOD.TBKHACHHANG (USERID);
;

-- DDL generated by DBeaver
-- WARNING: It may differ from actual native database DDL

-- Drop table

-- DROP TABLE SHIPFOOD.TBKHUYENMAI;

CREATE TABLE SHIPFOOD.TBKHUYENMAI (
	MAKM NUMBER(10,0) DEFAULT "SHIPFOOD"."ISEQ$$_73519".nextval,
	TENKM VARCHAR2(100),
	MOTA VARCHAR2(500),
	LOAIKM VARCHAR2(200),
	PHANTRAMGIAM NUMBER(3,0),
	DIEUKIEN VARCHAR2(500),
	NGAYBATDAU TIMESTAMP,
	NGAYKETTHUC TIMESTAMP,
	CONSTRAINT CK_TBKM_NGAY CHECK (ngayketthuc IS NULL OR ngaybatdau IS NULL OR ngayketthuc >= ngaybatdau),
	CONSTRAINT CK_TBKM_PT CHECK (phantramgiam BETWEEN 0 AND 100),
	CONSTRAINT PK_TBKHUYENMAI PRIMARY KEY (MAKM),
	CONSTRAINT SYS_C008942 CHECK ("MAKM" IS NOT NULL),
	CONSTRAINT SYS_C008943 CHECK ("TENKM" IS NOT NULL),
	CONSTRAINT SYS_C008944 CHECK ("LOAIKM" IS NOT NULL)
);
CREATE UNIQUE INDEX PK_TBKHUYENMAI ON SHIPFOOD.TBKHUYENMAI (MAKM);
;

-- DDL generated by DBeaver
-- WARNING: It may differ from actual native database DDL

-- Drop table

-- DROP TABLE SHIPFOOD.TBLICHSUSUDUNGKHUYENMAI;

CREATE TABLE SHIPFOOD.TBLICHSUSUDUNGKHUYENMAI (
	ID NUMBER(10,0) DEFAULT "SHIPFOOD"."ISEQ$$_73561".nextval,
	USERID NUMBER(10,0),
	MAKM NUMBER(10,0),
	NGAYDUNG TIMESTAMP DEFAULT SYSTIMESTAMP ,
	MADH NUMBER(10,0),
	CONSTRAINT PK_TBLSKM PRIMARY KEY (ID),
	CONSTRAINT SYS_C009005 CHECK ("ID" IS NOT NULL),
	CONSTRAINT SYS_C009006 CHECK ("USERID" IS NOT NULL),
	CONSTRAINT SYS_C009007 CHECK ("MAKM" IS NOT NULL),
	CONSTRAINT SYS_C009008 CHECK ("NGAYDUNG" IS NOT NULL),
	CONSTRAINT UQ_TBLSKM_USER_KM UNIQUE (USERID,MAKM),
	CONSTRAINT FK_TBLSKM_DH FOREIGN KEY (MADH) REFERENCES SHIPFOOD.TBDONHANG(MADH) ON DELETE SET NULL,
	CONSTRAINT FK_TBLSKM_KM FOREIGN KEY (MAKM) REFERENCES SHIPFOOD.TBKHUYENMAI(MAKM),
	CONSTRAINT FK_TBLSKM_USER FOREIGN KEY (USERID) REFERENCES SHIPFOOD.TBUSER(USERID)
);
CREATE INDEX IX_TBLSKM_DH ON SHIPFOOD.TBLICHSUSUDUNGKHUYENMAI (MADH);
CREATE INDEX IX_TBLSKM_KM ON SHIPFOOD.TBLICHSUSUDUNGKHUYENMAI (MAKM);
CREATE UNIQUE INDEX PK_TBLSKM ON SHIPFOOD.TBLICHSUSUDUNGKHUYENMAI (ID);
CREATE UNIQUE INDEX UQ_TBLSKM_USER_KM ON SHIPFOOD.TBLICHSUSUDUNGKHUYENMAI (USERID,MAKM);
;

-- DDL generated by DBeaver
-- WARNING: It may differ from actual native database DDL

-- Drop table

-- DROP TABLE SHIPFOOD.TBLICHSUTRANGTHAIDON;

CREATE TABLE SHIPFOOD.TBLICHSUTRANGTHAIDON (
	ID NUMBER(10,0) DEFAULT "SHIPFOOD"."ISEQ$$_73580".nextval,
	MADH NUMBER(10,0),
	TRANGTHAI_CU VARCHAR2(50),
	TRANGTHAI_MOI VARCHAR2(50),
	THOIGIAN TIMESTAMP DEFAULT SYSTIMESTAMP ,
	GHICHU VARCHAR2(200),
	CONSTRAINT PK_TBLS_TRANGTHAI PRIMARY KEY (ID),
	CONSTRAINT SYS_C009014 CHECK ("ID" IS NOT NULL),
	CONSTRAINT SYS_C009015 CHECK ("MADH" IS NOT NULL),
	CONSTRAINT SYS_C009016 CHECK ("TRANGTHAI_MOI" IS NOT NULL),
	CONSTRAINT SYS_C009017 CHECK ("THOIGIAN" IS NOT NULL),
	CONSTRAINT FK_TBLS_DONHANG FOREIGN KEY (MADH) REFERENCES SHIPFOOD.TBDONHANG(MADH) ON DELETE CASCADE
);
CREATE INDEX IX_TBLS_MADH ON SHIPFOOD.TBLICHSUTRANGTHAIDON (MADH);
CREATE INDEX IX_TBLS_THOIGIAN ON SHIPFOOD.TBLICHSUTRANGTHAIDON (THOIGIAN);
CREATE UNIQUE INDEX PK_TBLS_TRANGTHAI ON SHIPFOOD.TBLICHSUTRANGTHAIDON (ID);
;

-- DDL generated by DBeaver
-- WARNING: It may differ from actual native database DDL

-- Drop table

-- DROP TABLE SHIPFOOD.TBLOAIHINHTHANHTOAN;

CREATE TABLE SHIPFOOD.TBLOAIHINHTHANHTOAN (
	MAHTTT NUMBER(10,0) DEFAULT "SHIPFOOD"."ISEQ$$_73527".nextval,
	TENHINHTHUC VARCHAR2(100),
	MOTA VARCHAR2(500),
	CONSTRAINT PK_TBLOAIHINHTT PRIMARY KEY (MAHTTT),
	CONSTRAINT SYS_C008956 CHECK ("MAHTTT" IS NOT NULL),
	CONSTRAINT SYS_C008957 CHECK ("TENHINHTHUC" IS NOT NULL),
	CONSTRAINT UQ_TBLOAIHINHTT_TEN UNIQUE (TENHINHTHUC)
);
CREATE UNIQUE INDEX PK_TBLOAIHINHTT ON SHIPFOOD.TBLOAIHINHTHANHTOAN (MAHTTT);
CREATE UNIQUE INDEX UQ_TBLOAIHINHTT_TEN ON SHIPFOOD.TBLOAIHINHTHANHTOAN (TENHINHTHUC);
;

-- DDL generated by DBeaver
-- WARNING: It may differ from actual native database DDL

-- Drop table

-- DROP TABLE SHIPFOOD.TBMONAN;

CREATE TABLE SHIPFOOD.TBMONAN (
	MAMON NUMBER(10,0) DEFAULT "SHIPFOOD"."ISEQ$$_73509".nextval,
	TENMON VARCHAR2(100),
	MOTA VARCHAR2(500),
	HINHANH VARCHAR2(500),
	MAQUANAN NUMBER(10,0),
	MADANHMUC NUMBER(10,0),
	CONHANG BOOLEAN DEFAULT TRUE  ,
	ISDELETED BOOLEAN DEFAULT FALSE ,
	CONSTRAINT PK_TBMONAN PRIMARY KEY (MAMON),
	CONSTRAINT SYS_C008929 CHECK ("MAMON" IS NOT NULL),
	CONSTRAINT SYS_C008930 CHECK ("TENMON" IS NOT NULL),
	CONSTRAINT SYS_C008931 CHECK ("CONHANG" IS NOT NULL),
	CONSTRAINT SYS_C008932 CHECK ("ISDELETED" IS NOT NULL),
	CONSTRAINT FK_TBMONAN_DM FOREIGN KEY (MADANHMUC) REFERENCES SHIPFOOD.TBDANHMUC(MADANHMUC),
	CONSTRAINT FK_TBMONAN_QUAN FOREIGN KEY (MAQUANAN) REFERENCES SHIPFOOD.TBQUANAN(USERID)
);
CREATE INDEX IX_TBMONAN_DM ON SHIPFOOD.TBMONAN (MADANHMUC);
CREATE INDEX IX_TBMONAN_QUAN_DM ON SHIPFOOD.TBMONAN (MAQUANAN,MADANHMUC);
CREATE UNIQUE INDEX PK_TBMONAN ON SHIPFOOD.TBMONAN (MAMON);
;

-- DDL generated by DBeaver
-- WARNING: It may differ from actual native database DDL

-- Drop table

-- DROP TABLE SHIPFOOD.TBMONANKHUYENMAI;

CREATE TABLE SHIPFOOD.TBMONANKHUYENMAI (
	ID NUMBER(10,0) DEFAULT "SHIPFOOD"."ISEQ$$_73522".nextval,
	MAKM NUMBER(10,0),
	MAMON NUMBER(10,0),
	SOLUONG NUMBER(10,0),
	TRANGTHAI VARCHAR2(50),
	PHANTRAMGIAM NUMBER(3,0) DEFAULT 0 ,
	CONSTRAINT CK_TBMONANKM_PT CHECK (phantramgiam BETWEEN 0 AND 100),
	CONSTRAINT CK_TBMONANKM_TT CHECK (trangthai IN ('Còn hạn','Hết hạn')),
	CONSTRAINT PK_TBMONANKM PRIMARY KEY (ID),
	CONSTRAINT SYS_C008948 CHECK ("ID" IS NOT NULL),
	CONSTRAINT SYS_C008949 CHECK ("PHANTRAMGIAM" IS NOT NULL),
	CONSTRAINT UQ_TBMONANKM UNIQUE (MAKM,MAMON),
	CONSTRAINT FK_TBMONANKM_BT FOREIGN KEY (MAMON) REFERENCES SHIPFOOD.TBBIENTHEMONAN(ID),
	CONSTRAINT FK_TBMONANKM_KM FOREIGN KEY (MAKM) REFERENCES SHIPFOOD.TBKHUYENMAI(MAKM) ON DELETE CASCADE
);
CREATE INDEX IX_TBMONANKM_MAMON ON SHIPFOOD.TBMONANKHUYENMAI (MAMON);
CREATE UNIQUE INDEX PK_TBMONANKM ON SHIPFOOD.TBMONANKHUYENMAI (ID);
CREATE UNIQUE INDEX UQ_TBMONANKM ON SHIPFOOD.TBMONANKHUYENMAI (MAKM,MAMON);
;

-- DDL generated by DBeaver
-- WARNING: It may differ from actual native database DDL

-- Drop table

-- DROP TABLE SHIPFOOD.TBQUANAN;

CREATE TABLE SHIPFOOD.TBQUANAN (
	USERID NUMBER(10,0),
	TENQUANAN VARCHAR2(100),
	DIACHI VARCHAR2(250),
	TOADO VARCHAR2(100),
	SOLUOTDANHGIA NUMBER(10,0) DEFAULT 0,
	DIEMDANHGIA NUMBER(2,1),
	TRANGTHAI VARCHAR2(50),
	HINHANH VARCHAR2(500),
	CONSTRAINT CK_TBQUANAN_DIEM CHECK (diemdanhgia BETWEEN 0 AND 5),
	CONSTRAINT CK_TBQUANAN_TT CHECK (trangthai IN ('Đang mở cửa','Đóng cửa')),
	CONSTRAINT PK_TBQUANAN PRIMARY KEY (USERID),
	CONSTRAINT SYS_C008912 CHECK ("USERID" IS NOT NULL),
	CONSTRAINT SYS_C008913 CHECK ("TENQUANAN" IS NOT NULL),
	CONSTRAINT SYS_C008914 CHECK ("DIACHI" IS NOT NULL),
	CONSTRAINT FK_TBQUANAN_USER FOREIGN KEY (USERID) REFERENCES SHIPFOOD.TBUSER(USERID)
);
CREATE UNIQUE INDEX PK_TBQUANAN ON SHIPFOOD.TBQUANAN (USERID);
;

-- DDL generated by DBeaver
-- WARNING: It may differ from actual native database DDL

-- Drop table

-- DROP TABLE SHIPFOOD.TBSHIPPER;

CREATE TABLE SHIPFOOD.TBSHIPPER (
	USERID NUMBER(10,0),
	TENSHIPPER VARCHAR2(50),
	DIACHI VARCHAR2(250),
	TOADO VARCHAR2(100),
	DIEMDANHGIA NUMBER(2,1),
	SOLUOTDANHGIA NUMBER(10,0) DEFAULT 0,
	TRANGTHAI VARCHAR2(50),
	HINHANH VARCHAR2(500),
	CONSTRAINT CK_TBSHIPPER_DIEM CHECK (diemdanhgia BETWEEN 0 AND 5),
	CONSTRAINT CK_TBSHIPPER_TT CHECK (trangthai IN ('Đang hoạt động','Không hoạt động')),
	CONSTRAINT PK_TBSHIPPER PRIMARY KEY (USERID),
	CONSTRAINT SYS_C008919 CHECK ("USERID" IS NOT NULL),
	CONSTRAINT SYS_C008920 CHECK ("TENSHIPPER" IS NOT NULL),
	CONSTRAINT SYS_C008921 CHECK ("DIACHI" IS NOT NULL),
	CONSTRAINT FK_TBSHIPPER_USER FOREIGN KEY (USERID) REFERENCES SHIPFOOD.TBUSER(USERID)
);
CREATE UNIQUE INDEX PK_TBSHIPPER ON SHIPFOOD.TBSHIPPER (USERID);
;

-- DDL generated by DBeaver
-- WARNING: It may differ from actual native database DDL

-- Drop table

-- DROP TABLE SHIPFOOD.TBTHONGTINDATHANG;

CREATE TABLE SHIPFOOD.TBTHONGTINDATHANG (
	MATTDH NUMBER(10,0) DEFAULT "SHIPFOOD"."ISEQ$$_73531".nextval,
	SDT VARCHAR2(11),
	DIACHI VARCHAR2(250),
	TOADO VARCHAR2(100),
	TENNGUOINHAN VARCHAR2(50),
	USERID NUMBER(10,0),
	CONSTRAINT PK_TBTTDH PRIMARY KEY (MATTDH),
	CONSTRAINT SYS_C008960 CHECK ("MATTDH" IS NOT NULL),
	CONSTRAINT SYS_C008961 CHECK ("SDT" IS NOT NULL),
	CONSTRAINT SYS_C008962 CHECK ("DIACHI" IS NOT NULL),
	CONSTRAINT SYS_C008963 CHECK ("TENNGUOINHAN" IS NOT NULL),
	CONSTRAINT FK_TBTTDH_KH FOREIGN KEY (USERID) REFERENCES SHIPFOOD.TBKHACHHANG(USERID)
);
CREATE INDEX IX_TBTTDH_USER ON SHIPFOOD.TBTHONGTINDATHANG (USERID);
CREATE UNIQUE INDEX PK_TBTTDH ON SHIPFOOD.TBTHONGTINDATHANG (MATTDH);
;

-- DDL generated by DBeaver
-- WARNING: It may differ from actual native database DDL

-- Drop table

-- DROP TABLE SHIPFOOD.TBTINNHAN;

CREATE TABLE SHIPFOOD.TBTINNHAN (
	MATN NUMBER(10,0) DEFAULT "SHIPFOOD"."ISEQ$$_73552".nextval,
	MADH NUMBER(10,0),
	NOIDUNG VARCHAR2(500),
	THOIGIAN TIMESTAMP DEFAULT SYSTIMESTAMP,
	MASHIPPER NUMBER(10,0),
	MAKH NUMBER(10,0),
	CONSTRAINT PK_TBTINNHAN PRIMARY KEY (MATN),
	CONSTRAINT SYS_C008989 CHECK ("MATN" IS NOT NULL),
	CONSTRAINT FK_TBTN_DH FOREIGN KEY (MADH) REFERENCES SHIPFOOD.TBDONHANG(MADH) ON DELETE CASCADE,
	CONSTRAINT FK_TBTN_KH FOREIGN KEY (MAKH) REFERENCES SHIPFOOD.TBKHACHHANG(USERID),
	CONSTRAINT FK_TBTN_SHIPPER FOREIGN KEY (MASHIPPER) REFERENCES SHIPFOOD.TBSHIPPER(USERID)
);
CREATE INDEX IX_TBTN_DH ON SHIPFOOD.TBTINNHAN (MADH,THOIGIAN);
CREATE UNIQUE INDEX PK_TBTINNHAN ON SHIPFOOD.TBTINNHAN (MATN);
;

-- DDL generated by DBeaver
-- WARNING: It may differ from actual native database DDL

-- Drop table

-- DROP TABLE SHIPFOOD.TBUSER;

CREATE TABLE SHIPFOOD.TBUSER (
	USERID NUMBER(10,0) DEFAULT "SHIPFOOD"."ISEQ$$_73493".nextval,
	USERNAME VARCHAR2(50),
	PWD VARCHAR2(255),
	LOAITAIKHOAN VARCHAR2(50),
	SDT VARCHAR2(11),
	VITIEN NUMBER(15,2) DEFAULT 0,
	EMAIL VARCHAR2(100),
	TRANGTHAI NUMBER(1,0) DEFAULT 1 ,
	CONSTRAINT CK_TBUSER_LOAI CHECK (loaitaikhoan IN ('Khách hàng','Quán ăn','Shipper','Admin')),
	CONSTRAINT CK_TBUSER_TT CHECK (trangthai IN (0,1,2,3)),
	CONSTRAINT CK_TBUSER_VI CHECK (vitien >= 0),
	CONSTRAINT PK_TBUSER PRIMARY KEY (USERID),
	CONSTRAINT SYS_C008892 CHECK ("USERID" IS NOT NULL),
	CONSTRAINT SYS_C008893 CHECK ("USERNAME" IS NOT NULL),
	CONSTRAINT SYS_C008894 CHECK ("PWD" IS NOT NULL),
	CONSTRAINT SYS_C008895 CHECK ("LOAITAIKHOAN" IS NOT NULL),
	CONSTRAINT SYS_C008896 CHECK ("SDT" IS NOT NULL),
	CONSTRAINT SYS_C008897 CHECK ("EMAIL" IS NOT NULL),
	CONSTRAINT SYS_C008898 CHECK ("TRANGTHAI" IS NOT NULL),
	CONSTRAINT UQ_TBUSER_EMAIL UNIQUE (EMAIL)
);
CREATE INDEX IX_TBUSER_LOAI_TT ON SHIPFOOD.TBUSER (LOAITAIKHOAN,TRANGTHAI);
CREATE UNIQUE INDEX PK_TBUSER ON SHIPFOOD.TBUSER (USERID);
CREATE UNIQUE INDEX UQ_TBUSER_EMAIL ON SHIPFOOD.TBUSER (EMAIL);
;

CREATE OR REPLACE FORCE EDITIONABLE VIEW "SHIPFOOD"."V_DATA_ANALYTIC" ("MAMONAN", "MAQUANAN", "TENMONAN", "HINHANH", "TENDANHMUC", "DIEMDANHGIA", "SODANHGIA", "GIATIEN", "SOLUONGBANDUOC", "CONHANG") AS 
  WITH sold AS (
    SELECT b.mamon, SUM(c.soluong) AS so_luong_ban
    FROM   tbChiTietDonHang c
    JOIN   tbBienTheMonAn b ON b.id = c.mamon
    GROUP  BY b.mamon
), rating AS (
    SELECT b.mamon, ROUND(AVG(g.diemdanhgia),1) AS diem, COUNT(*) AS so_danh_gia
    FROM   tbDanhGia g
    JOIN   tbChiTietDonHang c ON c.mactdh = g.mactdh
    JOIN   tbBienTheMonAn b   ON b.id = c.mamon
    GROUP  BY b.mamon
), price AS (
    SELECT mamon, MIN(giatien) AS gia FROM tbBienTheMonAn GROUP BY mamon
)
SELECT m.mamon        AS mamonan,
       m.maquanan,
       m.tenmon       AS tenmonan,
       m.hinhanh,
       dm.tendanhmuc,
       r.diem         AS diemdanhgia,
       r.so_danh_gia  AS sodanhgia,
       p.gia          AS giatien,
       NVL(s.so_luong_ban,0) AS soluongbanduoc,
       m.conhang
FROM   tbMonAn m
LEFT JOIN tbDanhMuc dm ON dm.madanhmuc = m.madanhmuc
LEFT JOIN sold   s ON s.mamon = m.mamon
LEFT JOIN rating r ON r.mamon = m.mamon
LEFT JOIN price  p ON p.mamon = m.mamon
WHERE  m.isDeleted = FALSE;
;

CREATE OR REPLACE FORCE EDITIONABLE VIEW "SHIPFOOD"."V_DATA_ANALYTIC_DANHMUC" ("MAQUANAN", "MADANHMUC", "TENDANHMUC", "HINHANH", "SOLUONGMONAN", "TONGSOLUONGBANRA", "DOANHTHU") AS 
  SELECT m.maquanan,
       dm.madanhmuc,
       dm.tendanhmuc,
       dm.hinhanh,
       COUNT(DISTINCT m.mamon)            AS soluongmonan,
       NVL(SUM(c.soluong),0)              AS tongsoluongbanra,
       NVL(SUM(c.soluong * c.dongia),0)   AS doanhthu
FROM   tbMonAn m
JOIN   tbDanhMuc dm ON dm.madanhmuc = m.madanhmuc
LEFT JOIN tbBienTheMonAn b   ON b.mamon = m.mamon
LEFT JOIN tbChiTietDonHang c ON c.mamon = b.id
WHERE  m.isDeleted = FALSE
GROUP  BY m.maquanan, dm.madanhmuc, dm.tendanhmuc, dm.hinhanh;
;

CREATE OR REPLACE FORCE EDITIONABLE VIEW "SHIPFOOD"."V_DON_HANG_DANG_LAM" ("MADH", "NGAYDATHANG", "TENNGUOINHAN", "DIACHI", "TENQUANAN", "DIACHIQUAN", "PHISHIP", "TONGTIEN", "TRANGTHAI", "SDT", "USERID") AS 
  SELECT d.madh,
       d.ngaydathang,
       t.tennguoinhan,
       t.diachi,
       q.tenquanan,
       q.diachi AS diachiquan,
       d.phiship,
       d.tongtien,
       d.trangthai,
       t.sdt,
       t.userid
FROM   tbDonHang d
JOIN   tbThongTinDatHang t ON t.mattdh = d.mattdh
JOIN   tbQuanAn q          ON q.userid = d.maquan;
;

CREATE OR REPLACE FORCE EDITIONABLE VIEW "SHIPFOOD"."V_LICH_SU_DON_HANG" ("MADH", "NGAYDATHANG", "TRANGTHAI", "DIACHI", "TENNGUOINHAN", "PHISHIP", "MASHIPPER", "USERID") AS 
  SELECT d.madh,
       d.ngaydathang,
       d.trangthai,
       t.diachi,
       t.tennguoinhan,
       d.phiship,
       d.mashipper,
       t.userid
FROM   tbDonHang d
JOIN   tbThongTinDatHang t ON t.mattdh = d.mattdh;
;

CREATE OR REPLACE FUNCTION SHIPFOOD.fn_dem_don_dang_xu_ly (
    p_userid   IN NUMBER,
    p_loai_tk  IN VARCHAR2          -- 'Quán ăn' | 'Shipper'
) RETURN NUMBER
AS
    v_count NUMBER := 0;
BEGIN
    IF p_loai_tk = 'Quán ăn' THEN
        SELECT COUNT(*)
        INTO   v_count
        FROM   tbDonHang
        WHERE  maquan = p_userid
          AND  trangthai IN ('Chờ xác nhận', 'Đã đặt', 'Đang chuẩn bị', 'Đang giao');
          
    ELSIF p_loai_tk = 'Shipper' THEN
        SELECT COUNT(*)
        INTO   v_count
        FROM   tbDonHang
        WHERE  mashipper = p_userid
          AND  trangthai IN ('Đang giao');
    END IF;
    
    RETURN v_count;
END;

CREATE OR REPLACE FUNCTION SHIPFOOD.fn_kiem_tra_chuyen_trang_thai (
    p_trangthai_cu  IN VARCHAR2,
    p_trangthai_moi IN VARCHAR2
) RETURN BOOLEAN
AS
    v_old VARCHAR2(50) := NVL(p_trangthai_cu, 'NULL');
    v_new VARCHAR2(50) := p_trangthai_moi;
BEGIN
    IF v_old = v_new THEN
        RETURN TRUE;
    END IF;
    
    RETURN (
           (v_old = 'Chờ xác nhận' AND v_new IN ('Đã đặt', 'Hủy đơn'))
        OR (v_old = 'Đã đặt'       AND v_new IN ('Đang chuẩn bị', 'Đang giao', 'Hủy đơn'))
        OR (v_old = 'Đang chuẩn bị' AND v_new IN ('Đang giao', 'Hủy đơn'))
        OR (v_old = 'Đang giao'    AND v_new IN ('Hoàn thành', 'Hủy đơn'))
    );
END;

CREATE OR REPLACE FUNCTION SHIPFOOD.fn_kiem_tra_km_hop_le (
    p_makm     IN NUMBER,
    p_userid   IN NUMBER DEFAULT NULL   -- để kiểm tra đã dùng chưa
) RETURN BOOLEAN
AS
    v_count      NUMBER;
    v_ngay_bd    TIMESTAMP;
    v_ngay_kt    TIMESTAMP;
BEGIN
    -- Kiểm tra tồn tại và còn hạn
    SELECT ngaybatdau, ngayketthuc
    INTO   v_ngay_bd, v_ngay_kt
    FROM   tbKhuyenMai
    WHERE  makm = p_makm;
    
    IF (v_ngay_bd IS NOT NULL AND SYSTIMESTAMP < v_ngay_bd)
       OR (v_ngay_kt IS NOT NULL AND SYSTIMESTAMP > v_ngay_kt) THEN
        RETURN FALSE;
    END IF;
    
    -- Kiểm tra user đã dùng mã này chưa (nếu có truyền userid)
    IF p_userid IS NOT NULL THEN
        SELECT COUNT(*)
        INTO   v_count
        FROM   tbLichSuSuDungKhuyenMai
        WHERE  userid = p_userid
          AND  makm   = p_makm;
          
        IF v_count > 0 THEN
            RETURN FALSE;   -- đã dùng rồi
        END IF;
    END IF;
    
    RETURN TRUE;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN FALSE;
END;

CREATE OR REPLACE FUNCTION SHIPFOOD.fn_kiem_tra_mon_con_hang (
    p_id_bienthe IN NUMBER          -- id của tbBienTheMonAn
) RETURN BOOLEAN
AS
    v_conhang   BOOLEAN;
    v_isdeleted BOOLEAN;
BEGIN
    SELECT m.conhang, m.isDeleted
    INTO   v_conhang, v_isdeleted
    FROM   tbBienTheMonAn b
    JOIN   tbMonAn m ON m.mamon = b.mamon
    WHERE  b.id = p_id_bienthe;
    
    RETURN (v_conhang = TRUE AND v_isdeleted = FALSE);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN FALSE;
END;

CREATE OR REPLACE FUNCTION SHIPFOOD.fn_kiem_tra_so_du (
    p_userid   IN NUMBER,
    p_so_tien  IN NUMBER
) RETURN BOOLEAN
AS
    v_so_du NUMBER(15,2);
BEGIN
    SELECT vitien INTO v_so_du
    FROM tbUser
    WHERE userid = p_userid;
    
    RETURN v_so_du >= p_so_tien;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN FALSE;
END;

CREATE OR REPLACE FUNCTION SHIPFOOD.fn_lay_gia_thap_nhat_mon (
    p_mamon IN NUMBER
) RETURN NUMBER
AS
    v_gia NUMBER(15,2);
BEGIN
    SELECT MIN(giatien)
    INTO   v_gia
    FROM   tbBienTheMonAn
    WHERE  mamon = p_mamon;
    
    RETURN NVL(v_gia, 0);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 0;
END;

CREATE OR REPLACE FUNCTION SHIPFOOD.fn_tinh_gia_sau_km (
    p_gia_goc       IN NUMBER,
    p_phantram_giam IN NUMBER
) RETURN NUMBER
AS
BEGIN
    IF p_phantram_giam IS NULL OR p_phantram_giam <= 0 THEN
        RETURN p_gia_goc;
    END IF;
    
    IF p_phantram_giam >= 100 THEN
        RETURN 0;
    END IF;
    
    RETURN ROUND(p_gia_goc * (1 - p_phantram_giam / 100), 0);
END;

CREATE OR REPLACE FUNCTION SHIPFOOD.fn_tinh_tong_tien_don (
    p_madh IN NUMBER
) RETURN NUMBER
AS
    v_tong_mon   NUMBER(15,2) := 0;
    v_phiship    NUMBER(15,2) := 0;
    v_phidichvu  NUMBER(15,2) := 0;
BEGIN
    SELECT NVL(SUM(soluong * NVL(dongia, 0)), 0)
    INTO   v_tong_mon
    FROM   tbChiTietDonHang
    WHERE  madh = p_madh;
    
    SELECT NVL(phiship, 0), NVL(phidichvu, 0)
    INTO   v_phiship, v_phidichvu
    FROM   tbDonHang
    WHERE  madh = p_madh;
    
    RETURN v_tong_mon + v_phiship + v_phidichvu;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 0;
END;

CREATE OR REPLACE PROCEDURE SHIPFOOD.sp_cap_nhat_mon_an (
    p_mamon       IN  NUMBER,
    p_tenmon      IN  VARCHAR2 DEFAULT NULL,
    p_mota        IN  VARCHAR2 DEFAULT NULL,
    p_hinhanh     IN  VARCHAR2 DEFAULT NULL,
    p_conhang     IN  BOOLEAN  DEFAULT NULL,
    p_is_deleted  IN  BOOLEAN  DEFAULT NULL,
    p_message     OUT VARCHAR2
) AS
BEGIN
    UPDATE tbMonAn
    SET tenmon    = NVL(p_tenmon, tenmon),
        mota      = NVL(p_mota, mota),
        hinhanh   = NVL(p_hinhanh, hinhanh),
        conhang   = NVL(p_conhang, conhang),
        isDeleted = NVL(p_is_deleted, isDeleted)
    WHERE mamon = p_mamon;
    
    IF SQL%ROWCOUNT = 0 THEN
        p_message := 'Không tìm thấy món ' || p_mamon;
    ELSE
        p_message := 'Cập nhật món thành công';
    END IF;
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        p_message := 'Lỗi: ' || SQLERRM;
END;

CREATE OR REPLACE PROCEDURE SHIPFOOD.sp_cap_nhat_trang_thai_don (
    p_madh          IN  NUMBER,
    p_trangthai_moi IN  VARCHAR2,
    p_userid_thuc_hien IN NUMBER,   -- người thực hiện (để audit sau này)
    p_message       OUT VARCHAR2
) AS
    v_trangthai_cu VARCHAR2(50);
BEGIN
    SELECT trangthai INTO v_trangthai_cu
    FROM tbDonHang
    WHERE madh = p_madh
    FOR UPDATE;
    
    UPDATE tbDonHang
    SET trangthai = p_trangthai_moi
    WHERE madh = p_madh;
    
    -- Các trigger sẽ tự chạy: kiểm soát trạng thái, ghi ngày, audit, tiền...
    
    p_message := 'Cập nhật trạng thái thành công: ' || v_trangthai_cu || ' → ' || p_trangthai_moi;
    COMMIT;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        p_message := 'Không tìm thấy đơn hàng ' || p_madh;
    WHEN OTHERS THEN
        ROLLBACK;
        p_message := 'Lỗi: ' || SQLERRM;
END;

CREATE OR REPLACE PROCEDURE SHIPFOOD.sp_danh_gia_don_hang (
    p_mactdh      IN  NUMBER,
    p_diem        IN  NUMBER,
    p_nhanxet     IN  VARCHAR2 DEFAULT NULL,
    p_hinhanh     IN  VARCHAR2 DEFAULT NULL,
    p_message     OUT VARCHAR2
) AS
    v_count NUMBER;
BEGIN
    -- Chỉ cho đánh giá 1 lần
    SELECT COUNT(*) INTO v_count FROM tbDanhGia WHERE mactdh = p_mactdh;
    IF v_count > 0 THEN
        p_message := 'Món này đã được đánh giá rồi';
        RETURN;
    END IF;
    
    IF p_diem NOT BETWEEN 1 AND 5 THEN
        p_message := 'Điểm đánh giá phải từ 1 đến 5';
        RETURN;
    END IF;
    
    INSERT INTO tbDanhGia (mactdh, diemdanhgia, nhanxet, hinhanh)
    VALUES (p_mactdh, p_diem, p_nhanxet, p_hinhanh);
    
    p_message := 'Đánh giá thành công';
    -- Trigger sẽ tự cập nhật điểm quán + shipper
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        p_message := 'Lỗi đánh giá: ' || SQLERRM;
END;

CREATE OR REPLACE PROCEDURE SHIPFOOD.sp_dat_hang (
    p_userid_kh       IN  NUMBER,
    p_maquan          IN  NUMBER,
    p_mattdh          IN  NUMBER,
    p_hinhthuctt      IN  NUMBER,
    p_makm            IN  NUMBER DEFAULT NULL,
    p_phiship         IN  NUMBER DEFAULT 0,
    p_phidichvu       IN  NUMBER DEFAULT 0,
    p_ghichu          IN  VARCHAR2 DEFAULT NULL,
    p_chi_tiet        IN  t_chi_tiet_don_list,   -- nested table
    p_madh_out        OUT NUMBER,
    p_message         OUT VARCHAR2
) AS
    v_tong_tien_mon   NUMBER(15,2) := 0;
    v_tong_tien       NUMBER(15,2);
    v_madh            NUMBER(10);
    
    -- Cursor duyệt danh sách chi tiết
    CURSOR c_chi_tiet IS
        SELECT mamon_bienthe, soluong, dongia
        FROM TABLE(p_chi_tiet);
BEGIN
    -- 1. Tính tổng tiền món bằng cursor
    FOR r IN c_chi_tiet LOOP
        IF r.soluong IS NULL OR r.soluong < 1 THEN
            RAISE_APPLICATION_ERROR(-20020, 'Số lượng phải >= 1');
        END IF;
        v_tong_tien_mon := v_tong_tien_mon + (r.soluong * NVL(r.dongia, 0));
    END LOOP;
    
    v_tong_tien := v_tong_tien_mon + NVL(p_phiship, 0) + NVL(p_phidichvu, 0);
    
    -- 2. Tạo đơn hàng
    INSERT INTO tbDonHang (
        maquan, mattdh, trangthai, tongtien,
        hinhthucthanhtoan, makhuyenmai, phiship, phidichvu, ghichu
    ) VALUES (
        p_maquan, p_mattdh, 'Chờ xác nhận', v_tong_tien,
        p_hinhthuctt, p_makm, p_phiship, p_phidichvu, p_ghichu
    ) RETURNING madh INTO v_madh;
    
    -- 3. Thêm chi tiết bằng cursor
    FOR r IN c_chi_tiet LOOP
        INSERT INTO tbChiTietDonHang (madh, mamon, soluong, dongia)
        VALUES (v_madh, r.mamon_bienthe, r.soluong, r.dongia);
    END LOOP;
    
    -- 4. Ghi lịch sử dùng khuyến mãi
    IF p_makm IS NOT NULL THEN
        INSERT INTO tbLichSuSuDungKhuyenMai (userid, makm, madh)
        VALUES (p_userid_kh, p_makm, v_madh);
    END IF;
    
    p_madh_out := v_madh;
    p_message  := 'Đặt hàng thành công. Mã đơn: ' || v_madh;
    COMMIT;
    
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        p_madh_out := NULL;
        p_message  := 'Lỗi đặt hàng: ' || SQLERRM;
END;

CREATE OR REPLACE PROCEDURE SHIPFOOD.sp_gan_shipper (
    p_madh        IN  NUMBER,
    p_mashipper   IN  NUMBER,
    p_message     OUT VARCHAR2
) AS
    v_trangthai   VARCHAR2(50);
    v_shipper_tt  VARCHAR2(50);
BEGIN
    -- Kiểm tra đơn
    SELECT trangthai INTO v_trangthai
    FROM tbDonHang WHERE madh = p_madh FOR UPDATE;
    
    IF v_trangthai NOT IN ('Đã đặt', 'Đang chuẩn bị', 'Đang giao') THEN
        p_message := 'Chỉ được gán shipper khi đơn ở trạng thái Đã đặt / Đang chuẩn bị / Đang giao';
        RETURN;
    END IF;
    
    -- Kiểm tra shipper đang hoạt động
    SELECT trangthai INTO v_shipper_tt
    FROM tbShipper WHERE userid = p_mashipper;
    
    IF v_shipper_tt <> 'Đang hoạt động' THEN
        p_message := 'Shipper không ở trạng thái Đang hoạt động';
        RETURN;
    END IF;
    
    UPDATE tbDonHang
    SET mashipper = p_mashipper,
        trangthai = CASE WHEN trangthai = 'Đã đặt' THEN 'Đang giao' ELSE trangthai END
    WHERE madh = p_madh;
    
    p_message := 'Gán shipper thành công';
    COMMIT;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        p_message := 'Không tìm thấy đơn hoặc shipper';
    WHEN OTHERS THEN
        ROLLBACK;
        p_message := 'Lỗi: ' || SQLERRM;
END;

CREATE OR REPLACE PROCEDURE SHIPFOOD.sp_huy_don_hang (
    p_madh      IN  NUMBER,
    p_lydo      IN  VARCHAR2 DEFAULT NULL,
    p_message   OUT VARCHAR2
) AS
BEGIN
    UPDATE tbDonHang
    SET trangthai = 'Hủy đơn',
        ghichu    = NVL(ghichu, '') || ' | Hủy: ' || NVL(p_lydo, 'Không rõ lý do')
    WHERE madh = p_madh
      AND trangthai NOT IN ('Hoàn thành', 'Hủy đơn');
    
    IF SQL%ROWCOUNT = 0 THEN
        p_message := 'Không thể hủy đơn (đơn không tồn tại hoặc đã hoàn thành/hủy)';
    ELSE
        p_message := 'Hủy đơn thành công';
        -- Trigger sẽ tự hoàn tiền + giải phóng KM + ghi audit
    END IF;
    
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        p_message := 'Lỗi hủy đơn: ' || SQLERRM;
END;

CREATE OR REPLACE PROCEDURE SHIPFOOD.sp_lay_don_hang_theo_vai_tro (
    p_userid      IN  NUMBER,
    p_loai_tk     IN  VARCHAR2,   -- 'Khách hàng' | 'Quán ăn' | 'Shipper' | 'Admin'
    p_trangthai   IN  VARCHAR2 DEFAULT NULL,
    p_cursor      OUT SYS_REFCURSOR
) AS
BEGIN
    IF p_loai_tk = 'Khách hàng' THEN
        OPEN p_cursor FOR
            SELECT d.madh, d.ngaydathang, d.trangthai, d.tongtien, d.phiship,
                   q.tenquanan, t.tennguoinhan, t.diachi
            FROM tbDonHang d
            JOIN tbThongTinDatHang t ON t.mattdh = d.mattdh
            JOIN tbQuanAn q ON q.userid = d.maquan
            WHERE t.userid = p_userid
              AND (p_trangthai IS NULL OR d.trangthai = p_trangthai)
            ORDER BY d.ngaydathang DESC;
            
    ELSIF p_loai_tk = 'Quán ăn' THEN
        OPEN p_cursor FOR
            SELECT d.madh, d.ngaydathang, d.trangthai, d.tongtien,
                   t.tennguoinhan, t.sdt, t.diachi, d.ghichu
            FROM tbDonHang d
            JOIN tbThongTinDatHang t ON t.mattdh = d.mattdh
            WHERE d.maquan = p_userid
              AND (p_trangthai IS NULL OR d.trangthai = p_trangthai)
            ORDER BY d.ngaydathang DESC;
            
    ELSIF p_loai_tk = 'Shipper' THEN
        OPEN p_cursor FOR
            SELECT d.madh, d.ngaydathang, d.trangthai, d.phiship,
                   t.tennguoinhan, t.sdt, t.diachi, q.tenquanan, q.diachi AS diachi_quan
            FROM tbDonHang d
            JOIN tbThongTinDatHang t ON t.mattdh = d.mattdh
            JOIN tbQuanAn q ON q.userid = d.maquan
            WHERE d.mashipper = p_userid
              AND (p_trangthai IS NULL OR d.trangthai = p_trangthai)
            ORDER BY d.ngaydathang DESC;
            
    ELSE -- Admin
        OPEN p_cursor FOR
            SELECT d.madh, d.ngaydathang, d.trangthai, d.tongtien,
                   q.tenquanan, t.tennguoinhan
            FROM tbDonHang d
            JOIN tbThongTinDatHang t ON t.mattdh = d.mattdh
            JOIN tbQuanAn q ON q.userid = d.maquan
            WHERE (p_trangthai IS NULL OR d.trangthai = p_trangthai)
            ORDER BY d.ngaydathang DESC;
    END IF;
END;

CREATE OR REPLACE PROCEDURE SHIPFOOD.sp_them_mon_an (
    p_maquan      IN  NUMBER,
    p_tenmon      IN  VARCHAR2,
    p_mota        IN  VARCHAR2 DEFAULT NULL,
    p_hinhanh     IN  VARCHAR2 DEFAULT NULL,
    p_madanhmuc   IN  NUMBER,
    p_bien_the    IN  t_bien_the_list,     -- nested table
    p_mamon_out   OUT NUMBER,
    p_message     OUT VARCHAR2
) AS
    v_mamon NUMBER(10);
    
    CURSOR c_bien_the IS
        SELECT tensize, giatien
        FROM TABLE(p_bien_the);
BEGIN
    -- 1. Thêm món
    INSERT INTO tbMonAn (tenmon, mota, hinhanh, maquanan, madanhmuc, conhang, isDeleted)
    VALUES (p_tenmon, p_mota, p_hinhanh, p_maquan, p_madanhmuc, TRUE, FALSE)
    RETURNING mamon INTO v_mamon;
    
    -- 2. Thêm biến thể bằng cursor
    FOR r IN c_bien_the LOOP
        INSERT INTO tbBienTheMonAn (mamon, tensize, giatien)
        VALUES (v_mamon, r.tensize, r.giatien);
    END LOOP;
    
    p_mamon_out := v_mamon;
    p_message  := 'Thêm món thành công. Mã món: ' || v_mamon;
    COMMIT;
    
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        p_mamon_out := NULL;
        p_message  := 'Lỗi thêm món: ' || SQLERRM;
END;

CREATE OR REPLACE PROCEDURE SHIPFOOD.sp_thong_ke_doanh_thu_quan (
    p_maquan      IN  NUMBER,
    p_tu_ngay     IN  TIMESTAMP,
    p_den_ngay    IN  TIMESTAMP,
    p_cursor      OUT SYS_REFCURSOR
) AS
BEGIN
    OPEN p_cursor FOR
        SELECT 
            TRUNC(d.ngaydathang) AS ngay,
            COUNT(*) AS so_don,
            SUM(CASE WHEN d.trangthai = 'Hoàn thành' THEN 1 ELSE 0 END) AS don_thanh_cong,
            SUM(CASE WHEN d.trangthai = 'Hủy đơn' THEN 1 ELSE 0 END) AS don_huy,
            SUM(CASE WHEN d.trangthai = 'Hoàn thành' 
                     THEN d.tongtien - NVL(d.phiship,0) - NVL(d.phidichvu,0) 
                     ELSE 0 END) AS doanh_thu_quan,
            SUM(CASE WHEN d.trangthai = 'Hoàn thành' THEN d.phiship ELSE 0 END) AS tong_phi_ship
        FROM tbDonHang d
        WHERE d.maquan = p_maquan
          AND d.ngaydathang BETWEEN p_tu_ngay AND p_den_ngay
        GROUP BY TRUNC(d.ngaydathang)
        ORDER BY ngay DESC;
END;

CREATE OR REPLACE PROCEDURE SHIPFOOD.sp_tim_kiem_mon_an (
    p_keyword     IN  VARCHAR2 DEFAULT NULL,
    p_maquan      IN  NUMBER DEFAULT NULL,
    p_madanhmuc   IN  NUMBER DEFAULT NULL,
    p_gia_tu      IN  NUMBER DEFAULT NULL,
    p_gia_den     IN  NUMBER DEFAULT NULL,
    p_cursor      OUT SYS_REFCURSOR
) AS
BEGIN
    OPEN p_cursor FOR
        SELECT m.mamon, m.tenmon, m.mota, m.hinhanh, m.conhang,
               q.tenquanan, q.diemdanhgia,
               dm.tendanhmuc,
               MIN(b.giatien) AS gia_thap_nhat,
               MAX(b.giatien) AS gia_cao_nhat
        FROM tbMonAn m
        JOIN tbQuanAn q ON q.userid = m.maquanan
        LEFT JOIN tbDanhMuc dm ON dm.madanhmuc = m.madanhmuc
        LEFT JOIN tbBienTheMonAn b ON b.mamon = m.mamon
        WHERE m.isDeleted = FALSE
          AND m.conhang = TRUE
          AND (p_keyword IS NULL OR UPPER(m.tenmon) LIKE '%' || UPPER(p_keyword) || '%')
          AND (p_maquan IS NULL OR m.maquanan = p_maquan)
          AND (p_madanhmuc IS NULL OR m.madanhmuc = p_madanhmuc)
        GROUP BY m.mamon, m.tenmon, m.mota, m.hinhanh, m.conhang,
                 q.tenquanan, q.diemdanhgia, dm.tendanhmuc
        HAVING (p_gia_tu IS NULL OR MIN(b.giatien) >= p_gia_tu)
           AND (p_gia_den IS NULL OR MIN(b.giatien) <= p_gia_den)
        ORDER BY q.diemdanhgia DESC NULLS LAST, m.tenmon;
END;

CREATE SEQUENCE SHIPFOOD."ISEQ$$_73493" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9999999999999999999999999999 NOCYCLE CACHE 20 NOORDER ;

CREATE SEQUENCE SHIPFOOD."ISEQ$$_73506" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9999999999999999999999999999 NOCYCLE CACHE 20 NOORDER ;

CREATE SEQUENCE SHIPFOOD."ISEQ$$_73509" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9999999999999999999999999999 NOCYCLE CACHE 20 NOORDER ;

CREATE SEQUENCE SHIPFOOD."ISEQ$$_73514" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9999999999999999999999999999 NOCYCLE CACHE 20 NOORDER ;

CREATE SEQUENCE SHIPFOOD."ISEQ$$_73519" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9999999999999999999999999999 NOCYCLE CACHE 20 NOORDER ;

CREATE SEQUENCE SHIPFOOD."ISEQ$$_73522" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9999999999999999999999999999 NOCYCLE CACHE 20 NOORDER ;

CREATE SEQUENCE SHIPFOOD."ISEQ$$_73527" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9999999999999999999999999999 NOCYCLE CACHE 20 NOORDER ;

CREATE SEQUENCE SHIPFOOD."ISEQ$$_73531" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9999999999999999999999999999 NOCYCLE CACHE 20 NOORDER ;

CREATE SEQUENCE SHIPFOOD."ISEQ$$_73535" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9999999999999999999999999999 NOCYCLE CACHE 20 NOORDER ;

CREATE SEQUENCE SHIPFOOD."ISEQ$$_73543" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9999999999999999999999999999 NOCYCLE CACHE 20 NOORDER ;

CREATE SEQUENCE SHIPFOOD."ISEQ$$_73548" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9999999999999999999999999999 NOCYCLE CACHE 20 NOORDER ;

CREATE SEQUENCE SHIPFOOD."ISEQ$$_73552" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9999999999999999999999999999 NOCYCLE CACHE 20 NOORDER ;

CREATE SEQUENCE SHIPFOOD."ISEQ$$_73556" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9999999999999999999999999999 NOCYCLE CACHE 20 NOORDER ;

CREATE SEQUENCE SHIPFOOD."ISEQ$$_73561" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9999999999999999999999999999 NOCYCLE CACHE 20 NOORDER ;

CREATE SEQUENCE SHIPFOOD."ISEQ$$_73580" INCREMENT BY 1 MINVALUE 1 MAXVALUE 9999999999999999999999999999 NOCYCLE CACHE 20 NOORDER ;