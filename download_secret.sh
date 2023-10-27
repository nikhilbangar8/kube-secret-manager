
#!/bin/sh

namespace=default
# list of contexts
ctx_array=("dev" "staging")
# list of secrets 
secret_array=("my-secrets")

current_time=$(date "+%Y%m%d_%H%M%S")
for ctx in ${ctx_array[@]}
do 
    echo "-------------=================---------------" 
    kubectx $ctx #> /dev/null
    kubectl config current-context #> /dev/null
    
    for secret_name in ${secret_array[@]}
    do 
        directory_to_save=$ctx/$secret_name
        values=$(kubectl --namespace $namespace get secrets $secret_name -o json \
            | jq -r '.data | keys[] as $k | "\($k):\(.[$k])"')
        if [[ $values == "" ]]
        then
            echo "Secret is not present in the Cluster or not found"
        else
            mkdir -p secrets/$directory_to_save
            mkdir -p backup/$directory_to_save
            for file_content in $values
            do
                file_name=$(echo $file_content | cut -d':' -f1)
                echo $file_content | cut -d':' -f2 | base64 --decode > secrets/$directory_to_save/$file_name
                basename=${file_name%.*}    # Remove extension
                extension=${file_name##*.}  # Remove basename
                echo $file_content | cut -d':' -f2 | base64 --decode > backup/$directory_to_save/"$basename"_"$current_time.$extension"
                echo "Created $directory_to_save/$file_name"
            done
        fi
        
    done       
done

