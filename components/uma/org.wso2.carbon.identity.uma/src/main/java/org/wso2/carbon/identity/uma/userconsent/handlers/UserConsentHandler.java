/*
 *
 * Copyright (c) 2005-2015, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
 *
 * WSO2 Inc. licenses this file to you under the Apache License,
 * Version 2.0 (the "License"); you may not use this file except
 * in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 * /
 */

package org.wso2.carbon.identity.uma.userconsent.handlers;

import org.wso2.carbon.identity.uma.userconsent.UmaReqMessageContext;

public interface UserConsentHandler {

    /**
     *  initialization logic for the handler
     */
    public void init();

    /**
     * Calculate the priority for the handler based on contents of the Request Message context
     * @param umaReqMessageContext
     * @return int priority (default value is 1)
     */
    public int getPriority(UmaReqMessageContext umaReqMessageContext);


    public boolean canHandleUserConsentType(UmaReqMessageContext umaReqMessageContext);

    public void issueRPT(UmaReqMessageContext umaReqMessageContext);

    public void validateScope(UmaReqMessageContext umaReqMessageContext);

    public boolean requestStepUpAuthentication(UmaReqMessageContext umaReqMessageContext);

    public boolean requireClaims(UmaReqMessageContext umaReqMessageContext);

}