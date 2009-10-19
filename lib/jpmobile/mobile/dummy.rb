module Jpmobile::Mobile
  class Dummy < AbstractMobile
    USER_AGENT_REGEXP = %r{DummyMobile}
    # 対応するメールアドレスの正規表現
    MAIL_ADDRESS_REGEXP = /^.+@dummy-mobile\.ne\.jp$/
    def dummy_uid
      if @request.env['HTTP_USER_AGENT'] =~ /DummyMobile\(ID:(.+);cookie:(.+);\)/
        return $1
      else
        nil
      end
    end
    def supports_cookie?
      if @request.env['HTTP_USER_AGENT'] =~ /DummyMobile\(ID:(.+);cookie:(.+);\)/
        return $2 == "true"
      else
        true
      end
    end
    alias :ident_subscriber :dummy_uid
  end
end
