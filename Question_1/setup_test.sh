mkdir -p ./submissions

# 3 Unique Submissions 
echo "Student A - Database Design Assignment - ER Diagrams and Normalization" > ./submissions/student_a_assignment1.txt
echo "Student B - Network Topology Report - OSI Model Explained" > ./submissions/student_b_assignment1.txt
echo "Student C - Operating Systems Concepts - Process Scheduling" > ./submissions/student_c_assignment1.txt

#  1 Standalone Uniqu
echo "Student D - SQL Query Optimization Techniques" > ./submissions/student_d_duplicate.txt

cp ./submissions/student_a_assignment1.txt ./submissions/student_e_copy.txt
cp ./submissions/student_b_assignment1.txt ./submissions/student_f_copy.txt
cp ./submissions/student_c_assignment1.txt ./submissions/student_g_resubmission.txt

echo "=== Test Setup Complete ==="
echo "Total files: $(find ./submissions -type f | wc -l)"
echo "Unique: 4  |  Duplicates: 3"
echo ""
echo "File list:"
ls -1 ./submissions/
