public with sharing class Logger implements IService {

    public interface IService {
        
        void error(String message);
		void error(String message, Object obj);
		void error(String message, List<Object> objects);
        
        void warn(String message);
		void warn(String message, Object obj);
		void warn(String message, List<Object> objects);

		void info(String message);
		void info(String message, Object obj);
		void info(String message, List<Object> objects);

        void debug(String message);
		void debug(String message, Object obj);
		void debug(String message, List<Object> objects);

        void fine(String message);
		void fine(String message, Object obj);
		void fine(String message, List<Object> objects);

        void finer(String message);
		void finer(String message, Object obj);
		void finer(String message, List<Object> objects);

        void finest(String message);
		void finest(String message, Object obj);
		void finest(String message, List<Object> objects);
    }

	public interface IBuilder {
		IBuilder setLoglevel(Logginglevel logLevel);

		IBuilder setErrorLogLevel();
		IBuilder setWarnLogLevel();
		IBuilder setInfoLogLevel();
		IBuilder setDebugLogLevel();
		IBuilder setFineLogLevel();
		IBuilder setFinerLogLevel();
		IBuilder setFinestLogLevel();

		IBuilder setStandardPrinting();
		IBuilder setJSONPrinting();
		IBuilder setJSONPrettyPrinting();

		IService build();
	}

    public class Builder implements IBuilder {

    	private final Type type;
    	private final Config config;

    	private Builder(Type type) {
    		this(type, new Config());
    	}

    	private Builder(Type type, Config config) {
    		this.config = config;
    		this.type = type;
    	}

		public IBuilder setLoglevel(Logginglevel logLevel) {
			this.config.logLevel = logLevel; return this;
		}

		public IBuilder setErrorLogLevel() {
			return setLogLevel(LoggingLevel.Error);
		}
		public IBuilder setWarnLogLevel() {
			return setLogLevel(LoggingLevel.Warn);
		}
		public IBuilder setInfoLogLevel() {
			return setLogLevel(LoggingLevel.Info);
		}
		public IBuilder setDebugLogLevel() {
			return setLogLevel(LoggingLevel.Debug);
		}
		public IBuilder setFineLogLevel() {
			return setLogLevel(LoggingLevel.Fine);
		}
		public IBuilder setFinerLogLevel() {
			return setLogLevel(LoggingLevel.Finer);
		}
		public IBuilder setFinestLogLevel() {
			return setLogLevel(LoggingLevel.Finest);
		}

		public IBuilder setStandardPrinting() {
			return setPrintingStyle(PrintStyle.Standard);
		}
		public IBuilder setJSONPrinting() {
			return setPrintingStyle(PrintStyle.JSON);
		}
		public IBuilder setJSONPrettyPrinting() {
			return setPrintingStyle(PrintStyle.JSONPretty);
		}

		private IBuilder setPrintingStyle(PrintStyle style) {
			this.config.style = style; return this;
		}

		public IService build() {
			return new Logger(this.type, this.config);
		}

    }

    private enum PrintStyle {
    	Standard, JSON, JSONPretty
    }

    private class Config {
    	private PrintStyle style = PrintStyle.Standard;
    	private LoggingLevel logLevel = LoggingLevel.Debug;
    }

    public static IBuilder getBuilder(Type type) {
    	return new Builder(type);
    }
    
    public static IService getDefault(Type type) {
        return getBuilder(type).build();
    }

    public static IService getPrettyDefault(Type type) {
    	return getBuilder(type).setJSONPrettyPrinting().build();
    }

    private final String logName;
    private final Config config;

    public Logger(Type type) {
    	this(type, new Config());
    }

    public Logger(Type type, Config config) {
    	this(type.getName(), config);
    }

    private Logger(String logName, Config config) {
    	this.logName = logName;
    	this.config = config;

        info('Logger init');
    }

    public void error(String message) {
    	error(message, new List<Object>());
    }
	public void error(String message, Object obj) {
		error(message, new List<Object>{ obj });
	}
	public void error(String message, List<Object> objects) {
		log(LoggingLevel.Error, message, objects);
	}
    
    public void warn(String message) {
    	warn(message, new List<Object>());
    }
	public void warn(String message, Object obj) {
		warn(message, new List<Object>{ obj });
	}
	public void warn(String message, List<Object> objects) {
		log(LoggingLevel.Warn, message, objects);
	}

	public void info(String message) {
		info(message, new List<Object>());
	}
	public void info(String message, Object obj) {
		info(message, new List<Object>{ obj });
	}
	public void info(String message, List<Object> objects) {
		log(LoggingLevel.Info, message, objects);
	}

    public void debug(String message) {
    	debug(message, new List<Object>());
    }
	public void debug(String message, Object obj) {
		debug(message, new List<Object>{ obj });
	}
	public void debug(String message, List<Object> objects) {
		log(LoggingLevel.Debug, message, objects);
	}

    public void fine(String message) {
    	fine(message, new List<Object>());
    }
	public void fine(String message, Object obj) {
		fine(message, new List<Object>{ obj });
	}
	public void fine(String message, List<Object> objects) {
		log(LoggingLevel.Fine, message, objects);
	}

    public void finer(String message) {
    	finer(message, new List<Object>());
    }
	public void finer(String message, Object obj) {
		finer(message, new List<Object>{ obj });
	}
	public void finer(String message, List<Object> objects) {
		log(LoggingLevel.Finer, message, objects);
	}

    public void finest(String message) {
    	finest(message, new List<Object>());
    }
	public void finest(String message, Object obj) {
		finest(message, new List<Object>{ obj });
	}
	public void finest(String message, List<Object> objects) {
		log(LoggingLevel.Finest, message, objects);
	}


    private void log(LoggingLevel level, String message, List<Object> objects) {
    	if(level.ordinal() < config.logLevel.ordinal()) return;

    	final String logMessage = '[' + logName + '] ' + message;
    	final String objectsStr = getObjectRepr(objects);

        System.debug(level, logMessage + objectsStr);
    }

    private String getObjectRepr(List<Object> objects) {
    	
    	if(objects.isEmpty()) return '';

    	if(PrintStyle.JSON == config.style) 
    		return '\n' + JSON.serialize(objects);

    	else if(PrintStyle.JSONPretty == config.style) 
    		return '\n' + JSON.serializePretty(objects);

    	return '\n' + String.valueOf(objects);
    }

    private class TheOnlyWayToGetAStackTraceException extends Exception{}
}