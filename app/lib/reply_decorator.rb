class ReplyDecorator
  RUMOR_TYPES = {
    "RUMOR" => "這是謠言",
    "NOT_RUMOR" => "這是真的",
    "OPINIONATED" => "個人觀點",
  }

  def initialize(replies)
    @replies = JSON.parse(replies)["data"]["GetArticle"]["articleReplies"]
    @final_reply = []
  end

  def prettify
    @final_reply << conclusion
    @final_reply += gather_reasons
    reminder = "\n---------------\n歡迎成為闢謠編輯，一起查資料幫大家破解謠言！\nhttps://cofacts.g0v.tw/"
    {
      type: 'text',
      text: @final_reply.join("\n---------------\n") + reminder,
    }
  end

  private

  def conclusion
    types = @replies.map { |r| r['reply']['type'] }
    return "👵 #{RUMOR_TYPES[types.first]}。" if types.uniq.one?
    return "👵 部分是謠言。" if types.any? 'RUMOR'
    return "👵 包含個人觀點。" if types.any? 'OPINIONATED'
  end

  def gather_reasons
    @replies.map do |r|
      type = r['reply']['type']
      reason = r['reply']['text']
      reference = r['reply']['reference']

      reply = "#{RUMOR_TYPES[type]}理由🔎:\n #{reason}"
      if reference
        reply += "\n 📖 #{reference} "
      elsif type == "OPINIONATED" && @replies.length == 1
         reply += "\n ⚠️️ 此回應沒有出處，此文章亦無其他觀點的回應，請自行斟酌回應之可信度。⚠️️ "
      else
         reply += "\n ⚠️️ 此回應沒有出處，請自行斟酌回應之可信度。⚠️️ "
      end
      reply
    end
  end
end
