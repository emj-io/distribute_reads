module DistributeReads
  module AppropriatePool
    def _appropriate_pool(*args)
      if Thread.current[:distribute_reads]
        if Thread.current[:distribute_reads][:primary] || needs_master?(*args) || (blacklisted = @slave_pool.completely_blacklisted?)
          check_if_writes_allowed
          raise DistributeReads::NoReplicasAvailable, "No replicas available" if blacklisted && Thread.current[:distribute_reads][:failover] == false
          stick_to_master(*args) if DistributeReads.by_default
          @master_pool
        elsif in_transaction?
          check_if_writes_allowed
          @master_pool
        else
          @slave_pool
        end
      elsif !DistributeReads.by_default
        @master_pool
      else
        super
      end
    end

    private

    def check_if_writes_allowed
      raise DistributeReads::WritesNotAllowed unless Thread.current[:distribute_reads][:allow_writes]
    end
  end
end
