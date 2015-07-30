module MemCacheStoreLogging
  def read_multi(*args)
    puts "read_multi(#{args.join(', ')})"
    super
  end

  def read_entry(*args)
    puts "read_entry(#{args.join(', ')})"
    super
  end

  def write_entry(*args)
    puts "write_entry(#{args.join(', ')})"
    super
  end

  def delete_entry(*args)
    puts "delete_entry(#{args.join(', ')})"
    super
  end
end

ActiveSupport::Cache::MemCacheStore.prepend(MemCacheStoreLogging)
