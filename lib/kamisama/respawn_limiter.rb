class Kamisama::RespawnLimiter

  def initialize(respawn_limit, respawn_interval)
    @respawn_limit = respawn_limit
    @respawn_interval = respawn_interval

    @respawns = []
  end

  def record!
    now = Time.now.to_i

    @respawns = @respawns.select { |timestamp| timestamp >= now - @respawn_interval } + [now]

    die_if_breached!
  end

  def calculate_respawn_count
    now = Time.now.to_i

    @respawns.count { |timestamp| timestamp > (now - @respawn_interval) }
  end

  def die_if_breached!
    respawn_count = calculate_respawn_count

    if respawn_count >= @respawn_limit
      puts "[Kamisama Master] Respawn count #{respawn_count} hit the limit of #{@respawn_limit} for the respawn interval of #{@respawn_interval} seconds."
      puts "[Kamisama Master] Terminating."

      exit(1)
    end
  end

end
