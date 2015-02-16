require "spec_helper.rb"

describe ChefSplunk::Helpers do 
  describe '#splunk_servers_lookup' do
    let(:dummy_recipe) { Class.new { include ChefSplunk::Helpers } }
    let(:node) { double("Node") }
    let(:host) { '10.10.15.43' }
    let(:port) { '1648' }

    it "performs a Chef search if provided a search query" do
      search_query = 'splunk_is_server:true AND chef_environment:_default'
      lookup_type = search_query

      splunk_server = Hash.new
      splunk_server['hostname'] = 'spelunker'
      splunk_server['ipaddress'] = host
      splunk_server['splunk'] = Hash.new
      splunk_server['splunk']['receiver_port'] = port

      allow(node).to receive(:[]).with('splunk').and_return({ 'server_lookup' => lookup_type })
      expect(dummy_recipe).to receive(:search).with(:node, search_query).and_return([splunk_server])
      
      expect(dummy_recipe.splunk_servers_lookup(node)).to eq(["#{host}:#{port}"])
    end

    it "fetches the server(s) from a databag if a bag and item are specified" do
      data_bag_name_and_item_name = ['splunk', 'servers']
      lookup_type = data_bag_name_and_item_name

      splunk_server = Hash.new
      splunk_server['host'] = host
      splunk_server['port'] = port

      allow(node).to receive(:[]).with('splunk').and_return({ 'server_lookup' => lookup_type })
      expect(dummy_recipe).to receive(:data_bag_item).with('splunk', 'servers').and_return({ 'servers' => [splunk_server] })

      expect(dummy_recipe.splunk_servers_lookup(node)).to eq(["#{host}:#{port}"])
    end

    it "fetches the server(s) from a node attribute if an attribute is specified" do
      lookup_type = { 'attrib' => 'servers' }
      
      attribs = { 
        'server_lookup' => lookup_type,
        'servers' => ["#{host}:#{port}"]
      }
      
      allow(node).to receive(:[]).with('splunk').and_return(attribs)

      expect(dummy_recipe.splunk_servers_lookup(node)).to eq(["#{host}:#{port}"])
    end
  end
end