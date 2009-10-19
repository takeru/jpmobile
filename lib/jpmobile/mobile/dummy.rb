module Jpmobile::Mobile
  class Dummy < AbstractMobile
    USER_AGENT_REGEXP = %r{DummyMobile}
    # 対応するメールアドレスの正規表現
    MAIL_ADDRESS_REGEXP = /^.+@dummy-mobile\.ne\.jp$/
    def dummy_uid
      "ABCDEFG"
    end
    alias :ident_subscriber :dummy_uid
  end
end
