# based on simple monad example
# use `import scheduler`
import pickups


scheduler = module("scheduler")


scheduler.init = def(m)
  class the_scheduler
    def init()
      print("Initializing scheduler")
      self.install_cron_job("get_pickups", "0 0 */12 * * *", pickups.gather, true)
      self.install_cron_job("set_rgbled", "0 0 14 * * *", pickups.check, true)
    end
    
    def install_cron_job(name, cronargs, fn, fire_on_install)
      print(f"Installing {name} CRON job")
      tasmota.add_cron(cronargs, fn, name)
      if(fire_on_install)
        tasmota.add_rule("Time#Initialized", fn)
      end
    end   
    
  end
  
  return the_scheduler()
end

return scheduler
