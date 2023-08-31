from acquire import acquire
import sys


def main():
    script_name = sys.argv[0]

    sys.argv.clear()
    sys.argv.append(script_name)
    sys.argv.append("--compress")
    sys.argv.append("-p")
    sys.argv.append("full")
    sys.argv.append("--history")
    sys.argv.append("--netstat")
    sys.argv.append("--win-processes")
    sys.argv.append("--win-proc-env")
    sys.argv.append("--win-arp-cache")
    sys.argv.append("--win-rdp-sessions")
    sys.argv.append("--win-notifications")
    sys.argv.append("--tasks")
    sys.argv.append("--exchange")
    sys.argv.append("--iis")
    sys.argv.append("--ntds")
    sys.argv.append("--prefetch")
    sys.argv.append("--appcompat")
    sys.argv.append("--pca")
    sys.argv.append("--syscache")
    sys.argv.append("--etl")
    sys.argv.append("--recents")
    sys.argv.append("--recyclebin")
    sys.argv.append("--drivers")
    sys.argv.append("--misc")
    sys.argv.append("--av")
    sys.argv.append("--quarantined")
    sys.argv.append("--remoteaccess")
    sys.argv.append("--wer")
    sys.argv.append("--handles")
    sys.argv.append("local")
    
    old_stdout = sys.stdout
    old_stderr = sys.stderr
    
    outfile = open("C:\\Dev\\acquire_log.log", "w")
    errfile = open("C:\\Dev\\acquire_err.log", "w")
    sys.stdout = outfile
    sys.stderr = errfile
    
    acquire.main()

    sys.stdout = old_stdout
    sys.stderr = old_stderr
    outfile.close()
    errfile.close()

if __name__ == '__main__':
    main()