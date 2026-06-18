from pydantic import BaseModel, EmailStr


class LoginRequest(BaseModel):
    email: str
    password: str


class LoginResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
    asesor: dict


class RegisterRequest(BaseModel):
    email: str
    password: str
    nombres: str
    apellidos: str
    telefono: str
    agencia_id: str
