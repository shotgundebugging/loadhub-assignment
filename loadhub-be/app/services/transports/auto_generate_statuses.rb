# frozen_string_literal: true

class Transports::AutoGenerateStatuses < Service::Base
  parameters :transport_id

  RADIUS_METERS      = 100.0
  SPEED_PAUSE_KMH    = 2.0
  SPEED_RESTART_KMH  = 5.0
  PAUSE_ITERATIONS   = 2

  State = Struct.new(:nearby, :pause_iterations, keyword_init: true) do
    def reset_pause!  = self.pause_iterations = 0
    def inc_pause!    = self.pause_iterations += 1
    def clear_nearby! = self.nearby = false
    def mark_nearby!  = self.nearby = true
  end

  def init
    @transport = Transport.find(transport_id)
    @current   = load_current_status || :draft
    @state     = State.new(nearby: false, pause_iterations: 0)
  end

  def call
    return if draft?

    prev = nil
    location_points.each do |curr|
      step(prev, curr)
      prev = curr
    end
  end

  private

  def load_current_status
    @transport.transport_statuses
      .order(happened_at: :desc, id: :desc)
      .first
      &.status
      &.to_sym
  end

  def location_points
    @transport.location_data.order(:timestamp, :id)
  end

  def step(prev, curr)
    apply(:finalise, prev, curr) if moving? || paused?

    apply(:start,    prev, curr) if ready?
    apply(:pause,    prev, curr) if moving?
    apply(:restart,  prev, curr) if paused?
  end

  def apply(rule, prev, curr)
    case rule
    when :start    then ready_to_moving(prev, curr)
    when :pause    then moving_to_paused(prev, curr)
    when :restart  then paused_to_moving(prev, curr)
    when :finalise then to_finalised(prev, curr)
    end
  end

  def ready_to_moving(_prev, curr)
    @state.mark_nearby! if within_start_radius?(curr)

    if @state.nearby && outside_start_radius?(curr)
      @state.clear_nearby!
      @state.reset_pause!
      transition!(:moving, curr.timestamp)
    end
  end

  def moving_to_paused(prev, curr)
    if speed_kmh(prev, curr) <= SPEED_PAUSE_KMH
      @state.inc_pause!
    else
      @state.reset_pause!
    end

    if @state.pause_iterations >= PAUSE_ITERATIONS
      @state.reset_pause!
      transition!(:paused, curr.timestamp)
    end
  end

  def paused_to_moving(prev, curr)
    return unless speed_kmh(prev, curr) > SPEED_RESTART_KMH

    @state.reset_pause!
    transition!(:moving, curr.timestamp)
  end

  def to_finalised(_prev, curr)
    return unless within_final_radius?(curr)

    @state.clear_nearby!
    @state.reset_pause!
    transition!(:finalised, curr.timestamp)
  end

  def transition!(to, at)
    from = current
    return if from == :draft || from == to

    @transport.transport_statuses.create!(status: to, happened_at: at)
    @current = to
  end

  def current = @current
  def draft?  = current == :draft
  def ready?  = current == :ready
  def moving? = current == :moving
  def paused? = current == :paused

  def within_start_radius?(curr)  = meters_to_start(curr) < RADIUS_METERS
  def outside_start_radius?(curr) = meters_to_start(curr) >= RADIUS_METERS
  def within_final_radius?(curr)  = meters_to_final(curr) < RADIUS_METERS

  def meters_to_start(curr)
    meters_between(lonlat(start_address), lonlat(curr))
  end

  def meters_to_final(curr)
    meters_between(lonlat(final_address), lonlat(curr))
  end

  def speed_kmh(prev, curr)
    return 0.0 unless prev

    dt = curr.timestamp.to_f - prev.timestamp.to_f
    return 0.0 if dt <= 0.0

    meters = meters_between(lonlat(prev), lonlat(curr))
    (meters / dt) * 3.6
  end

  def lonlat(obj) = [obj.longitude, obj.latitude]

  def meters_between(a_lonlat, b_lonlat)
    a_lon, a_lat = a_lonlat
    b_lon, b_lat = b_lonlat

    factory = RGeo::Geographic.spherical_factory
    factory.point(a_lon, a_lat).distance(factory.point(b_lon, b_lat))
  end

  def start_address = @transport.start_address
  def final_address = @transport.final_address
end

