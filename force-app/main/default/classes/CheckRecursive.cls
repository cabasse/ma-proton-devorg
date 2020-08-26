public class CheckRecursive {

    private static boolean running = false;

    public static boolean isRunning() {
        system.debug('running? ' + running);
        if(!running) {
            running = true;
            return false;
        } else {
            return running;
        }
    }
}
