
#!/bin/sh

namespace=default
# list of contexts
ctx_array=("dev" "staging")
# list of secrets 
secret_array=("my-secrets")


for ctx in ${ctx_array[@]}
do 
    echo "-------------=================---------------" 
    kubectx $ctx #> /dev/null
    kubectl config current-context #> /dev/null
    
    for secret_name in ${secret_array[@]}
    do
        directory_to_upload=secrets/$ctx/$secret_name
        if [[ -d "$directory_to_upload" ]]; 
        then
            echo "$directory_to_upload exists."
            echo "deleting secret $secret_name"
            kubectl delete secret $secret_name --namespace $namespace
            
            echo "Creating updated Secret $secret_name in the $ctx"
            kubectl create secret generic $secret_name --from-file=$directory_to_upload --namespace $namespace
            echo "updated Secret $secret_name in $ctx"
        else 
            echo "$directory_to_upload does not exists."
        fi
    done
done