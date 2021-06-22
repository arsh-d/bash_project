from argparse import ArgumentParser
import os
from subprocess import run, PIPE, STDOUT
from shutil import rmtree

# defining base directories
trainee_dir = '/home/trainee/courses'
source_dir = '/home/arsh/bash_project/project2_python/courses'

# course array
courses = [
    'Linux_course/Linux_course1',
    'Linux_course/Linux_course2',
    'machinelearning/machinelearning1',
    'machinelearning/machinelearning2',
    'SQLFundamentals1',
    'SQLFundamentals2',
    'SQLFundamentals3',
]

# function to check course is present
def check_course(course):
    #print(f"checking{course}")
    return course in courses

# function to check mount
def check_mount(course):

    course_path = os.path.join(trainee_dir,course)

    if os.path.isdir(course_path):
        #print("dir present")
        command1 = run(['mount'], stdin=PIPE, stdout=PIPE, stderr=STDOUT, text=True)
        command2 = run(['grep', course_path], stdout=PIPE, text=True, stderr=STDOUT, input=command1.stdout)
        if command2.returncode == 0:
            return True
        else:
            return False

def mount_course(course):

    if check_course(course):
        print("course found")
    if check_mount(course):
        print(f"{course}already mounted")
        return 0

    # making directory for the course
    mount_path = os.path.join(trainee_dir,course)
    os.makedirs(os.path.join(trainee_dir,course))
    course_source_dir = os.path.join(source_dir,course)

    # mount course
    mount_command = run(['bindfs', '-p', '550', '-u', 'trainee', '-g', 'ftpaccess', course_source_dir, mount_path], stdout=PIPE, stderr=STDOUT)
    if mount_command.returncode == 0:
        print(f"{course} mounted")
    else:
        # remove the created directory if course not mounted successfully
        rmtree(mount_path)
        print("mount error")
        return 1

    return 0

def unmount_course(course):

    if not check_course(course):
        print("course not found")
        return 1

    if check_mount(course):
        unmount_path = os.path.join(trainee_dir,course)
        # unmount the course
        unmount_command = run(['umount', unmount_path], stdout=PIPE, stderr=STDOUT)
        if unmount_command.returncode == 0:

            # if course contains subdirectories
            if '/' in course:
                course_base_dir = course.split('/')[0]
                del_path = os.path.join(trainee_dir,course_base_dir)
            else:
                del_path = unmount_path
            try:
                rmtree(del_path)
            except OSError:
                print('unmounting sub directories first !')
            
            print(f"unmounted: {course}")
        else:
            print("error in unmounting")
            return 1

    return 0

def mount_all():
    for course in courses:
        mount_course(course)
    return 0

def unmount_all():
    for course in courses:
        unmount_course(course)
    return 0


if __name__ == "__main__":
    parser = ArgumentParser()

    parser.add_argument('-m','--mount', help='mount a single given course', action='store_true')
    parser.add_argument('-u','--unmount', help='unmount a given course', action='store_true')
    parser.add_argument('-c','--course', help='name of course', type=str)

    arguments = parser.parse_args()

    if not arguments.mount and not arguments.unmount:
        parser.print_help()
    elif arguments.mount:
        if arguments.course:
            mount_course(arguments.course)
        else:
            mount_all()
    elif arguments.unmount:
        if arguments.course:
            unmount_course(arguments.course)
        else:
            unmount_all()