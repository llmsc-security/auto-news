#!/bin/bash
# Test file for entrypoint.sh functionality

# Test 1: Check that log function exists
test_log_function() {
    # Source the entrypoint.sh to get access to the log function
    source /home/taicen/wangjian/os_dev_google/docker_dirs_yuelin/repo_dirs/finaldie--auto-news/entrypoint.sh 2>/dev/null || true

    # Check if log function is defined
    if type log >/dev/null 2>&1; then
        echo "PASS: log function exists"
        return 0
    else
        echo "FAIL: log function not found"
        return 1
    fi
}

# Test 2: Check that install_runtime_dependencies function exists
test_install_runtime_dependencies() {
    source /home/taicen/wangjian/os_dev_google/docker_dirs_yuelin/repo_dirs/finaldie--auto-news/entrypoint.sh 2>/dev/null || true

    if type install_runtime_dependencies >/dev/null 2>&1; then
        echo "PASS: install_runtime_dependencies function exists"
        return 0
    else
        echo "FAIL: install_runtime_dependencies function not found"
        return 1
    fi
}

# Test 3: Check that check_requirements function exists
test_check_requirements() {
    source /home/taicen/wangjian/os_dev_google/docker_dirs_yuelin/repo_dirs/finaldie--auto-news/entrypoint.sh 2>/dev/null || true

    if type check_requirements >/dev/null 2>&1; then
        echo "PASS: check_requirements function exists"
        return 0
    else
        echo "FAIL: check_requirements function not found"
        return 1
    fi
}

# Test 4: Check that start_app function exists
test_start_app() {
    source /home/taicen/wangjian/os_dev_google/docker_dirs_yuelin/repo_dirs/finaldie--auto-news/entrypoint.sh 2>/dev/null || true

    if type start_app >/dev/null 2>&1; then
        echo "PASS: start_app function exists"
        return 0
    else
        echo "FAIL: start_app function not found"
        return 1
    fi
}

# Test 5: Check that entrypoint handles webserver argument
test_webserver_argument() {
    local entrypoint="/home/taicen/wangjian/os_dev_google/docker_dirs_yuelin/repo_dirs/finaldie--auto-news/entrypoint.sh"

    # Check that the entrypoint contains the webserver case
    if grep -q '"webserver"' "$entrypoint"; then
        echo "PASS: webserver argument case exists"
        return 0
    else
        echo "FAIL: webserver argument case not found"
        return 1
    fi
}

# Test 6: Check that entrypoint handles scheduler argument
test_scheduler_argument() {
    local entrypoint="/home/taicen/wangjian/os_dev_google/docker_dirs_yuelin/repo_dirs/finaldie--auto-news/entrypoint.sh"

    if grep -q '"scheduler"' "$entrypoint"; then
        echo "PASS: scheduler argument case exists"
        return 0
    else
        echo "FAIL: scheduler argument case not found"
        return 1
    fi
}

# Test 7: Check that entrypoint has correct shebang
test_shebang() {
    local entrypoint="/home/taicen/wangjian/os_dev_google/docker_dirs_yuelin/repo_dirs/finaldie--auto-news/entrypoint.sh"

    local first_line=$(head -n 1 "$entrypoint")
    if [[ "$first_line" == "#!/bin/bash" ]]; then
        echo "PASS: Correct shebang (#!/bin/bash)"
        return 0
    else
        echo "FAIL: Incorrect shebang: $first_line"
        return 1
    fi
}

# Test 8: Check that entrypoint uses set -e for error handling
test_error_handling() {
    local entrypoint="/home/taicen/wangjian/os_dev_google/docker_dirs_yuelin/repo_dirs/finaldie--auto-news/entrypoint.sh"

    if grep -q 'set -e' "$entrypoint"; then
        echo "PASS: Error handling (set -e) enabled"
        return 0
    else
        echo "FAIL: Error handling (set -e) not found"
        return 1
    fi
}

# Run all tests
main() {
    local passed=0
    local failed=0

    echo "Running entrypoint.sh tests..."
    echo "================================"

    for test in test_log_function test_install_runtime_dependencies test_check_requirements \
                test_start_app test_webserver_argument test_scheduler_argument test_shebang \
                test_error_handling; do
        echo -n "Testing $test... "
        if $test; then
            ((passed++))
        else
            ((failed++))
        fi
    done

    echo "================================"
    echo "Results: $passed passed, $failed failed"

    if [ $failed -gt 0 ]; then
        exit 1
    fi
    exit 0
}

main "$@"
