require 'openssl'

class Aes256Encrypter
  def self.encode(data)
    key = ENV['AES_256_KEY']
    cipher = OpenSSL::Cipher::AES256.new(:CBC)
    iv = cipher.random_iv
    cipher.encrypt
    cipher.key = key
    cipher.iv = iv
    ciphered = cipher.update(data)
    ciphered << cipher.final
    [ciphered, iv].map { |part| [part].pack('m').gsub(/\n/, '') }.join('--')
  end

  def self.decode(ciphered_message)
    key = ENV['AES_256_KEY']
    ciphered, iv = ciphered_message.split('--', 2).map { |part| part.unpack('m')[0] }
    decipher = OpenSSL::Cipher::AES256.new(:CBC)
    decipher.decrypt
    decipher.key = key
    decipher.iv = iv
    deciphered = decipher.update(ciphered)
    deciphered << decipher.final
  end
end
