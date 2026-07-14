class User < ApplicationRecord
  # Autenticação segura: guarda um hash bcrypt em password_digest (nunca a
  # senha em texto puro) e fornece os métodos `password=` e `authenticate`.
  has_secure_password

  # Um usuário é dono de várias fazendas; removê-lo apaga as fazendas em cascata.
  has_many :farms, dependent: :destroy

  # Padroniza o e-mail antes de validar/salvar: sem espaços e em minúsculas,
  # para que "  Joao@Fazenda.com " e "joao@fazenda.com" sejam tratados como iguais.
  normalizes :email, with: ->(email) { email.strip.downcase }

  validates :name, presence: true
  validates :email, presence: true,
                    uniqueness: true,
                    format: { with: URI::MailTo::EMAIL_REGEXP }

  # has_secure_password já exige a senha na criação; aqui garantimos um tamanho
  # mínimo. allow_nil permite atualizar o usuário sem precisar reenviar a senha.
  validates :password, length: { minimum: 8 }, allow_nil: true
end
