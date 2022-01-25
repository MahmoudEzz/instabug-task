require 'elasticsearch/model'

Elasticsearch::Model.client = Elasticsearch::Client.new url: 'es:9200', log: true