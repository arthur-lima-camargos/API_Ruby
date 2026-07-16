# Codifica e decodifica JSON Web Tokens usados na autenticação stateless.
#
# Usa o `secret_key_base` da aplicação como chave de assinatura, evitando
# introduzir um segredo novo no repositório. Tokens expiram por padrão em 24h
# (claim `exp`), e a decodificação valida a assinatura e a expiração — retornando
# `nil` para qualquer token ausente, malformado, adulterado ou expirado.
class JsonWebToken
  ALGORITHM = "HS256"
  DEFAULT_EXPIRATION = 24.hours

  class << self
    # `exp` é posicional (não keyword) para que `encode(user_id: 1)` funcione sem
    # chaves — com um keyword `exp:`, o Ruby leria `user_id:` como keyword.
    def encode(payload, exp = DEFAULT_EXPIRATION.from_now)
      JWT.encode(payload.merge(exp: exp.to_i), secret_key, ALGORITHM)
    end

    # Retorna o payload como HashWithIndifferentAccess, ou `nil` se o token for
    # inválido/expirado. O controller trata `nil` como não autenticado (401).
    def decode(token)
      payload, = JWT.decode(token, secret_key, true, algorithm: ALGORITHM)
      payload.with_indifferent_access
    rescue JWT::DecodeError
      nil
    end

    private

    def secret_key
      Rails.application.secret_key_base
    end
  end
end
