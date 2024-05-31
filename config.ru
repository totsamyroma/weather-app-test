# This file is used by Rack-based servers to start the application.

require_relative "config/environment"
require 'prometheus/middleware/exporter'

use Prometheus::Middleware::Exporter

run Rails.application
Rails.application.load_server

