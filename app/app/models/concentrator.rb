# == Schema Information
#
# Table name: concentrators
#
#  id         :bigint(8)        not null, primary key
#  address    :string
#  hostname   :string
#  login      :string
#  password   :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'mtik'

class Concentrator < ApplicationRecord

	# validações 
	validates :hostname, presence: true
	validates :address, presence: true
	validates :login, presence: true
	validates :password, presence: true

	def online?
		test_conection[:success]
	end

	def test_conection
		begin
        	mk = MTik::command(host: address, user: login, password: password, command: '/ip/address/print', conn_timeout: 5)
        	{message: mk, success: true, status: :ok}
      	rescue Exception=> e
       		{message: e.message , success: false, status: :error}
      	end
	end

	def info_concentrator
		if(online?)
			begin
				mtik = MTik::Connection.new host: address, user: login, password: password, conn_timeout: 1
				cpu_and_memory = mtik.get_reply '/system/resource/print'
				network = mtik.get_reply '/interface/monitor-traffic',
					'=interface=aggregate',
					'=.proplist=rx-bits-per-second,tx-bits-per-second',
					'=once='
				{success: true, cpu_and_memory: cpu_and_memory, network: network, status: :ok}
      		rescue Exception=> e
       			{ success: false, status: :error}
      		end			
		end
	end
end
