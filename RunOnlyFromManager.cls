public class RunOnlyFromManager {
    public static Boolean runTrigger = false;
    
    public static void executeTrigger(){
        runTrigger = true;
    }
}