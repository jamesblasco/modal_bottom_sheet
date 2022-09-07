PROJECT_PATH="${1:-.}"
genhtml coverage/lcov.info -o coverage | tee ./coverage/output.txt

COV_LINE=$(tail -2 ./coverage/output.txt | head -1)
SUB='100.0%'

if [[ "$COV_LINE" == *"$SUB"* ]]; then
    echo "The coverage is 100% for ${PROJECT_PATH}"
else
    echo "Coverage is below 100% for ${PROJECT_PATH}!"
    echo $COV_LINE
    open ./coverage/index.html
fi