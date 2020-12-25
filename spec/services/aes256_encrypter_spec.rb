require 'rails_helper'

RSpec.describe Aes256Encrypter do
  before do
    @message = {"access-token"=>"lgIMvjfX9JNeLDh4IwSi8w", "token-type"=>"Bearer", "client"=>"mbYscsQQHCIja4JAo28s3A", "expiry"=>"1610086793", "uid"=>"test@example.com"}.to_json
    @cipher_text = Aes256Encrypter.encode(@message)
  end

  it 'should encrypt given plain text' do
    cipher = Aes256Encrypter.encode(@message)

    expect(cipher).not_to eq(@message)
  end

  it 'should decrypt given plain text' do
    plain = Aes256Encrypter.decode(@cipher_text)

    expect(plain).not_to eq(@cipher_text)
    expect(plain).to eq(@message)
  end
end
