#!/bin/bash
#./course_mount.sh -h
#		Usage:
#			./course_mount.sh -h to print help message
#			./course_mount.sh -m -c [course] for mounting a given course
#			./course_mount.sh -u -c [course] for unmounting a given course
#		If course name is ommited all courses will be (un)mounted"
#
#
# -- The source DIR is /home/arsh/Desktop/bash_project_2/courses/
# -- Target DIR is /home/trainee/courses
# -- If a course contains multiple subcourses, the subcourses should be unmounted first.
#    
#



#array that holds the list of available courses
COURSES=(
"linux_course/linux_course1"
"linux_course/linux_course2"
"machinelearning/machinelearning1"
"machinelearning/machinelearning2"
"SQLfundamentals1"
"SQLfundamentals2"
"SQLfundamentals3"
)

print_help() {
	echo "./course_mount.sh -h
		Usage:
			./course_mount.sh -h to print help message
			./course_mount.sh -m -c [course] for mounting a given course
			./course_mount.sh -u -c [course] for unmounting a given course
		If course name is ommited all courses will be (un)mounted"
}

########################################## function to mount a course ############################################
mount_course() {

#--------------------check if course is available in array------------------------#
	FLAG=1
	for COURSE in ${COURSES[@]}     # traversing the courses array
	do
		if [[ $COURSE == $1 ]]  # if course is found in the array, break the loop.
		then 
			FLAG=0
			break 
		else
			continue
		fi
	done
	if [[ $FLAG == 1 ]]
	then
		echo "$1 not available"
		exit 1
	fi
	echo "ready to mount $1"
	

#--------------------check if mount already exists-----------------------------------#

mount | grep /home/trainee/courses/$1 > /dev/null 
STAT=$(echo $?)                                        # store the exit status of the command 
if [[ $STAT == 0 ]]					 # if exit status = 0, command executed successfully course is alread mounted
then							 # if exit status != 0, command execution failure
	echo "$1 already mounted"
	exit 0
else
	echo "mounting $1"
fi

#--------------------creating target DIR and mounting------------------------------------#

mkdir -p /home/trainee/courses/$1			
#chown -R trainee:ftpaccess /home/trainee/courses/$1 
bindfs -p a-w -u trainee -g ftpaccess /home/arsh/Desktop/bash_project_2/courses/$1 /home/trainee/courses/$1
echo "$1 mounted succesfully"

}

#################################### function to mount all ###########################################

mount_all() {
	for COURSE in ${COURSES[@]}
	do
		mount | grep /home/trainee/courses/$COURSE > /dev/null	# store the exit status of the command
		STAT=$(echo $?)						# if exit status = 0, command executed successfully 
										# course is alread mounted
		if [[ $STAT == 0 ]]						# if exit status != 0, command execution failure
		then
			echo "$COURSE already mounted"
			continue
		else
			echo "mounting $COURSE"
			mkdir -p /home/trainee/courses/$COURSE
			#chown -R trainee:ftpaccess /home/trainee/courses/$COURSE
			bindfs -p a-w -u trainee -g ftpaccess /home/arsh/Desktop/bash_project_2/courses/$COURSE /home/trainee/courses/$COURSE
			echo "$COURSE mounted successfully"
		fi
	done
}

################################### function to unmount a course #####################################

unmount_course() {
	
	mount | grep /home/trainee/courses/$COURSE > /dev/null
	STAT=$(echo $?)
	if [[ $STAT == 0 ]]
	then
		echo "unmounting $COURSE"
		sudo umount /home/trainee/courses/$1
		echo "$1 unmounted succesfully"
		rm -r /home/trainee/courses/$1				# recursively removing directory
		echo "$1 directory deleted successfully !"
	else
		echo "$1 already unmounted"
	fi
}

################################### function to unmount all courses ###################################

unmount_all() {
	for COURSE in ${COURSES[@]}
	do
		mount | grep /home/trainee/courses/$COURSE > /dev/null
		STAT=$(echo $?)
		if [[ $STAT == 0 ]]
		then
			echo "unmounting $COURSE"
			sudo umount /home/trainee/courses/$COURSE
			echo "$COURSE unmounted succesfully"
			rm -r /home/trainee/courses/${COURSE%%/*}		# recursively removing directory
			echo "$COURSE directory deleted successfully !"
		else
			echo "$COURSE already unmounted"
		fi
	done
}


################################## usage function ######################################################
usage () {
	if [[ $1 == "-h" ]] #if slected option is -h print help.
	then
		print_help
	elif [[ $1 == "-m" && $2 == "-c" ]]  #if course is specified, mount it.
	then
		mount_course $3
	elif [[ $1 == "-u" && $2 == "-c" ]]  #if course is specified, unmout it.
	then
		unmount_course $3
	elif [[ $1 == "-m" ]]                #if course is not specified, mount all.  
	then 
		echo "mounting all course"
		mount_all
	elif [[ $1 == "-u" ]]                #if course is not specified, unmount all.
	then
		echo "unmounting all course"
		unmount_all
	else
		echo "provide proper input"
	fi
}

usage $1 $2 $3 				#passing command line argument value to usage()

exit 0
