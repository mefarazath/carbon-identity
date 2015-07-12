/*
 *
 *  *
 *  * Copyright (c) 2005-2015, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
 *  *
 *  * WSO2 Inc. licenses this file to you under the Apache License,
 *  * Version 2.0 (the "License"); you may not use this file except
 *  * in compliance with the License.
 *  * You may obtain a copy of the License at
 *  *
 *  * http://www.apache.org/licenses/LICENSE-2.0
 *  *
 *  * Unless required by applicable law or agreed to in writing,
 *  * software distributed under the License is distributed on an
 *  * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 *  * KIND, either express or implied.  See the License for the
 *  * specific language governing permissions and limitations
 *  * under the License.
 *  * /
 *
 */

package org.wso2.carbon.identity.uma.dto;

import org.wso2.carbon.identity.uma.beans.protection.ResourceSetDescriptionBean;

import javax.servlet.http.HttpServletRequest;

public class UmaResourceSetRegistrationRequest extends UmaRequest{

    private ResourceSetDescriptionBean resourceSetDescription;
    private int resourceId;

    public UmaResourceSetRegistrationRequest(HttpServletRequest httpServletRequest) {
        super(httpServletRequest);
    }

    public void setResourceSetDescription(ResourceSetDescriptionBean resourceSetDescription) {
        this.resourceSetDescription = resourceSetDescription;
    }

    public void setResourceId(int resourceId) {
        this.resourceId = resourceId;
    }

    public ResourceSetDescriptionBean getResourceSetDescription() {
        return resourceSetDescription;
    }

    public int getResourceId() {
        return resourceId;
    }
}
