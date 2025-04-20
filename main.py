from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import List
from sqlalchemy import create_engine, Column, Integer, String
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker

DATABASE_URL = "postgresql://postgres:post12345@localhost:5432/banka_app"

engine = create_engine(DATABASE_URL)
SessionLocal = sessionmaker(bind=engine)
Base = declarative_base()

app = FastAPI()

# CORS Ayarları
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Üretimde sadece frontend IP eklenmeli!
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Ana Sayfa
@app.get("/")
def root():
    return {"message": "FastAPI çalışıyor!"}

# SQLAlchemy Model
class Musteri(Base):
    __tablename__ = "musteri"
    id = Column(Integer, primary_key=True, index=True)
    ad = Column(String)
    soyad = Column(String)
    yas = Column(Integer)
    calisma_durumu = Column(String)
    kredi_puani = Column(Integer)

Base.metadata.create_all(bind=engine)

# Pydantic Modeller
class MusteriCreate(BaseModel):
    ad: str
    soyad: str
    yas: int
    calisma_durumu: str
    kredi_puani: int

class MusteriOut(MusteriCreate):
    id: int

# CRUD İşlemleri
@app.post("/musteri/", response_model=MusteriOut)
def musteri_ekle(musteri: MusteriCreate):
    db = SessionLocal()
    db_musteri = Musteri(**musteri.dict())
    db.add(db_musteri)
    db.commit()
    db.refresh(db_musteri)
    db.close()
    return db_musteri

@app.get("/musteri/", response_model=List[MusteriOut])
def musteri_listele():
    db = SessionLocal()
    musteriler = db.query(Musteri).all()
    db.close()
    return musteriler

@app.put("/musteri/{musteri_id}", response_model=MusteriOut)
def musteri_guncelle(musteri_id: int, guncel_musteri: MusteriCreate):
    db = SessionLocal()
    musteri = db.query(Musteri).filter(Musteri.id == musteri_id).first()
    if not musteri:
        raise HTTPException(status_code=404, detail="Müşteri bulunamadı")
    for key, value in guncel_musteri.dict().items():
        setattr(musteri, key, value)
    db.commit()
    db.refresh(musteri)
    db.close()
    return musteri

@app.delete("/musteri/{musteri_id}")
def musteri_sil(musteri_id: int):
    db = SessionLocal()
    musteri = db.query(Musteri).filter(Musteri.id == musteri_id).first()
    if not musteri:
        raise HTTPException(status_code=404, detail="Müşteri bulunamadı")
    db.delete(musteri)
    db.commit()
    db.close()
    return {"message": "Müşteri silindi"}
