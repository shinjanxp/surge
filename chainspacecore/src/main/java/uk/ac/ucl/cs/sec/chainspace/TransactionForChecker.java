package uk.ac.ucl.cs.sec.chainspace;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import org.json.JSONObject;

import java.security.NoSuchAlgorithmException;

/**
 *
 *
 */
class TransactionForChecker {
    private String   contractID;
    private String[] inputs;
    private String[] referenceInputs;
    private String[] parameters;
    private String[] returns;
    private String[] outputs;
    private String[] dependencies;
    private String   methodID;

    /**
     * constructor
     */
    TransactionForChecker(
            String   contractID,
            String[] inputs,
            String[] referenceInputs,
            String[] parameters,
            String[] returns,
            String[] outputs,
            String[] dependencies,
            String   methodID
    ) {
        this.contractID       = contractID;
        this.inputs           = inputs;
        this.referenceInputs  = referenceInputs;
        this.parameters       = parameters;
        this.returns          = returns;
        this.outputs          = outputs;
        this.dependencies     = dependencies;
        this.methodID         = methodID;
    }


    /**
     * fromJson
     * Returns a transaction object from a json string representing it
     */
    static TransactionForChecker fromJson(JSONObject json) {
        Gson gson = new GsonBuilder().create();
        return gson.fromJson(json.toString(), TransactionForChecker.class);
    }

    /**
     * toJson
     * Returns a json string representing the transaction
     */
    String toJson() {
        Gson gson = new GsonBuilder().create();
        return gson.toJson(this);
    }


    /**
     * getID
     * Get the transaction's ID.
     */
    String getID() throws NoSuchAlgorithmException {
        return Utils.hash(this.toJson());
    }

    /*
        getters
     */
    String getContractID() {
        return contractID;
    }

    String[] getInputs() {

        return inputs;
    }

    String[] getReferenceInputs() {
        return referenceInputs;
    }

    String[] getParameters() {

        return parameters;
    }

    String[] getReturns() {

        return returns;
    }

    String[] getDependencies() {

        return dependencies;
    }

    String[] getOutputs() {

        return outputs;
    }

    String getMethodID() {
        return methodID;
    }
}