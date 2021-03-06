require 'pony'

class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :detect_region, :set_current_user

  rescue_from ActionView::MissingTemplate do
  end

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to '/users/sign_in', alert: exception.message
  end

  def add_host_info_to_subject(subject)
    server_name = request.host =~ /pinballmapstaging/ ? '(STAGING) ' : ''

    server_name + subject
  end

  def send_new_machine_notification(machine, location)
    Pony.mail(
      to: Region.find_by_name('portland').users.map { |u| u.email },
      from: 'admin@pinballmap.com',
      subject: add_host_info_to_subject('PBM - New machine name'),
      body: [machine.name, location.name, location.region.name, "(entered from #{request.remote_ip} via #{request.user_agent})"].join("\n")
    )
  end

  def send_new_location_notification(params, region)
    Pony.mail(
      to: region.users.map { |u| u.email },
      bcc: User.all.select { |u| u.is_super_admin }.map { |u| u.email },
      from: 'admin@pinballmap.com',
      subject: add_host_info_to_subject("PBM - New location suggested for the #{region.name} pinball map"),
      body: <<END
(A new pinball spot has been submitted for your region! Please verify the address on http://maps.google.com and then paste that Google Maps address into http://pinballmap.com/admin. Thanks!)\n
Location Name: #{params['location_name']}\n
Street: #{params['location_street']}\n
City: #{params['location_city']}\n
State: #{params['location_state']}\n
Zip: #{params['location_zip']}\n
Phone: #{params['location_phone']}\n
Website: #{params['location_website']}\n
Operator: #{params['location_operator']}\n
Machines: #{params['location_machines']}\n
Their Name: #{params['submitter_name']}\n
Their Email: #{params['submitter_email']}\n
(entered from #{request.remote_ip} via #{request.user_agent})\n
END
    )
  end

  def send_new_region_notification(params)
    Pony.mail(
      to: Region.where('lower(name) = ?', 'portland').first.users.map { |u| u.email },
      from: 'admin@pinballmap.com',
      subject: add_host_info_to_subject('PBM - New region suggestion'),
      body: <<END
Their Name: #{params['name']}\n
Their Email: #{params['email']}\n
Region Name: #{params['region_name']}\n
Region Comments: #{params['comments']}\n
END
    )
  end

  def send_admin_notification(params, region)
    Pony.mail(
      to: region.users.map { |u| u.email },
      bcc: User.all.select { |u| u.is_super_admin }.map { |u| u.email },
      from: 'admin@pinballmap.com',
      subject: add_host_info_to_subject("PBM - New message from the #{region.full_name} region"),
      body: <<END
Their Name: #{params['name']}\n
Their Email: #{params['email']}\n
Message: #{params['message']}\n
END
    )
  end

  def send_app_comment(params, region)
    Pony.mail(
      to: 'pinballmap@outlook.com',
      bcc: User.all.select { |u| u.is_super_admin }.map { |u| u.email },
      from: 'admin@pinballmap.com',
      subject: add_host_info_to_subject('PBM - App feedback'),
      body: <<END
OS: #{params['os']}\n
OS Version: #{params['os_version']}\n
Device Type: #{params['device_type']}\n
App Version: #{params['app_version']}\n
Region: #{region.name}\n
Their Name: #{params['name']}\n
Their Email: #{params['email']}\n
Message: #{params['message']}\n
END
    )
  end

  def return_response(data, root, includes = [], methods = [], http_status = 200)
    render json: { root => data.as_json(include: includes, methods: methods, root: false) }, status: http_status
  end

  def allow_cors
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Request-Method'] = '*'
    headers['Access-Control-Allow-Methods'] = %w(GET POST PUT DELETE OPTIONS).join(',')
    headers['Access-Control-Allow-Headers'] = %w(Origin Accept Content-Type X-Requested-With X-CSRF-Token).join(',')

    head(:ok) if request.request_method == 'OPTIONS'
  end

  private

  def after_sign_in_path_for(*)
    '/admin'
  end

  def mobile_device?
    if session[:mobile_param]
      session[:mobile_param] == '1'
    else
      (request.user_agent =~ /Mobile|webOS/) && (request.user_agent !~ /iPad/)
    end
  end

  helper_method :mobile_device?

  protected

  def detect_region
    @region = Region.find_by_name(params[:region].downcase) if params[:region] && (params[:region].is_a? String)
  end

  def set_current_user
    Authorization.current_user = current_user
  end
end
